# Copilot instructions for `rexport`

## Build, test, lint

This repo is a Ruby/Rails **gem** (bundler-managed).

- Install dependencies:
  - `bundle install`
- Run lint (RuboCop):
  - `bin/rubocop`
- Run the full test suite:
  - `bin/test`
- Run a single test file:
  - `bin/test test/lib/rexport/formatter_test.rb`
- Gem build/release tasks (Bundler gem tasks):
  - `bundle exec rake build`
  - `bundle exec rake install`
  - `bundle exec rake release`

Ruby version is pinned in `.ruby-version`.

## High-level architecture

### Rails engine that ships UI + mixins

- `lib/rexport.rb` defines `Rexport::Engine < Rails::Engine` and adds the gem’s `app/views` path.
- The gem ships Rails views/partials under `app/views/**` plus an `ExportsHelper` in `app/helpers/exports_helper.rb`.
- Routes live in `config/routes.rb` and define the `exports`, `export_items`, `export_filters`, and `export_item_sorting` endpoints.

### Core domain model is split into concerns

The gem expects the host app to have ActiveRecord models that include these concerns:

- Export model includes `Rexport::ExportMethods` (`lib/rexport/export_methods.rb`)
  - Owns `export_items` (columns/ordering) and `export_filters` (where conditions).
  - Produces output via `#to_csv` / `#to_s`.
- ExportItem model includes `Rexport::ExportItemMethods` (`lib/rexport/export_item_methods.rb`)
  - Stores `rexport_field` (a field “path”) and `name`.
  - Ordering is via `acts_as_list` + `.ordered` scope.
- ExportFilter model includes `Rexport::ExportFilterMethods` (`lib/rexport/export_filter_methods.rb`)
  - Stores `filter_field` and `value` and contributes to `WHERE` conditions.

Controllers are also provided as mixins (modules) rather than concrete controllers:

- `Rexport::ExportsControllerMethods`
- `Rexport::ExportItemsControllerMethods`
- `Rexport::ExportFiltersControllerMethods`
- `Rexport::ExportItemSortingsControllerMethods`

### Exportable models opt-in via `Rexport::DataFields`

Any model that can be exported includes `Rexport::DataFields` (`lib/rexport/data_fields.rb`). The export pipeline is:

1. `ExportMethods#rexport_model` builds a `Rexport::RexportModel` for the selected `model_class_name`.
2. `RexportModel` seeds fields from `klass.content_columns` and then calls the optional hook:
   - `YourModel.initialize_local_rexport_fields(rexport_model)`
3. Export items store `rexport_field` strings (e.g. `"student.family.name"` or `"grade"`).
4. `RexportModel#get_rexport_methods` maps those field names into method strings.
5. Each record calls `DataFields#export(...)` which uses `instance_eval` on each method string and formats values through `Rexport::Formatter`.

### Association traversal + eager loading

- `ExportMethods#rexport_models` recursively discovers export-capable associated models (belongs_to/has_one) and avoids infinite loops.
- `ExportMethods#build_include` uses `Rexport::TreeNode` to turn dotted paths into an `includes(...)` structure to reduce N+1 queries.

## Key conventions (repo-specific)

### `Export.models` must be overridden

`Rexport::ExportMethods` defines a placeholder `Export.models` implementation. In a host app, override `.models` to return the allowed model class names for the “Create New Export” dropdown (see `app/views/exports/index.html.erb`).

### Defining extra export fields

Exportable models can add custom fields and association-derived fields via:

- `initialize_local_rexport_fields(rexport_model)`
  - `rexport_model.add_rexport_field(:foo_method, method: :foo)`
  - `rexport_model.add_association_methods(associations: %w[status ilp_status])`

For association filter dropdown collections, a model can define:

- `find_<association>_for_rexport` (e.g. `find_family_for_rexport`), otherwise `RexportModel` falls back to `Association.klass.all`.

### `rexport_field` path format

- Paths are dot-separated (e.g. `"student.family.name"`).
- Association-derived fields created by `add_association_methods` produce names like `"status_name"` and methods like `"status.name"`.

### How `rexport_fields` updates affect ordering

`ExportMethods#rexport_fields=` treats the input shape as meaningful:

- If passed an **Array** of field names, export item positions will be updated to match the array order.
- If passed a **Hash** (typical checkbox params), export items are added/removed but existing positions are *not* reordered.

### Filter param shape and behavior

- Views/helpers build filter inputs as:
  - `export[export_filter_attributes][<filter_field>] = <value>`
- `ExportMethods#export_filter_attributes=` interprets blank values as “delete the filter”.

### Drag/drop sorting contract

- The export show view renders a sortable tbody with `data-url` set to `export_item_sorting_path`.
- Sorting posts `sorted_items` containing DOM ids; `ExportItemMethods.resort` strips non-digits from each id before `find(...)`.

### Schema expectation: `export_filters.filter_field`

Code/tests expect the `export_filters` table to have a `filter_field` column.

The bundled migration in `db/migrate/20091105182959_create_export_tables.rb` currently creates `export_filters.field`; when integrating into a host app, ensure the column name matches what the code uses (`filter_field`).

### Shipped views assume host-app helpers/assets

The ERB templates call helper methods like `link_to_delete`, `link_to_cancel`, `link_to_export`, and `print_date`, and reference icon images (e.g. `icon_edit.gif`). In a host app, either provide these helpers/assets or override the views in your application.
