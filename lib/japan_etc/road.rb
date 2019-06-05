# frozen_string_literal: true

require 'japan_etc/error'
require 'japan_etc/util'

module JapanETC
  Road = Struct.new(:name, :route_name) do
    def initialize(name, route_name = nil)
      raise ValidationError, '#name cannot be nil' if name.nil?

      super(normalize(name), normalize(route_name))
    end

    def normalize(string)
      Util.convert_fullwidth_characters_to_halfwidth(string)
    end
  end
end
