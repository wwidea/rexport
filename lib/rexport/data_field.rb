module Rexport
  class DataField
    include Comparable
    attr_accessor :name, :method, :type

    # Stores the name and method of the export data item
    def initialize(name, options = {})
      self.name = name.to_s
      self.method = options[:method].blank? ? self.name : options[:method].to_s
      self.type = options[:type]
    end

    def <=>(rf)
      self.name <=> rf.name
    end
  end
end
