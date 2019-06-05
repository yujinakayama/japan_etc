# frozen_string_literal: true

require 'japan_etc/error'
require 'japan_etc/util'

module JapanETC
  class Road
    attr_reader :name, :route_name

    def initialize(name, route_name = nil)
      raise ValidationError, '#name cannot be nil' if name.nil?

      @name = normalize(name)
      @route_name = normalize(route_name)
    end

    def to_a
      [name, route_name]
    end

    def normalize(string)
      Util.convert_fullwidth_characters_to_halfwidth(string)
    end
  end
end
