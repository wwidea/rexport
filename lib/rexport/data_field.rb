# frozen_string_literal: true

module Rexport
  class DataField
    include Comparable

    attr_reader :name, :method, :type

    # Stores the name and method of the export data item
    def initialize(name, options = {})
      @name   = name.to_s
      @method = options[:method].blank? ? self.name : options[:method].to_s
      @type   = options[:type]
    end

    # Sort by name
    def <=>(other)
      name <=> other.name
    end

    # Returns the first association name from a method chain string. If the string does not contain
    # the dot operator a nil is returned.
    #
    # Examples:
    #
    #   "assocation.method" # => "association"
    #   "assocation_one.assocation_two.method" # => "assocation_one"
    #   "method" # => nil
    def association_name
      method[0..(first_dot_index - 1)] if first_dot_index.present?
    end

    private

    def first_dot_index
      @first_dot_index ||= method.index(".")
    end
  end
end
