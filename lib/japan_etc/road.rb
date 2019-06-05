# frozen_string_literal: true

require 'japan_etc/error'

module JapanETC
  class Road
    attr_reader :name, :route_name

    def initialize(name, route_name = nil)
      raise ValidationError, '#name cannot be nil' if name.nil?

      @name = name
      @route_name = route_name
    end

    def to_a
      [name, route_name]
    end
  end
end
