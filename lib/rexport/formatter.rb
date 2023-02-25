# frozen_string_literal: true

module Rexport
  module Formatter
    def self.convert(value)
      case value
      when Date, Time
        value.strftime("%m/%d/%y")
      when TrueClass
        "Y"
      when FalseClass
        "N"
      else
        value.to_s
      end
    end
  end
end
