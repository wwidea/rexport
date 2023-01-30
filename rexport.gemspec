require_relative "lib/rexport/version"

Gem::Specification.new do |spec|
  spec.name        = "rexport"
  spec.version     = Rexport::VERSION
  spec.authors     = ["Aaron Baldwin", "Brightways Learning"]
  spec.email       = ["baldwina@brightwayslearning.org"]
  spec.homepage    = "https://github.com/wwidea/rexport"
  spec.summary     = "Ruby on Rails gem to manage exports."
  spec.description = "Rexport integrates into a Rails application making model data available for export into CSV files."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 2.7.0"
  spec.add_runtime_dependency "rails", ">= 6.0.3"
end
