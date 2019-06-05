# frozen_string_literal: true

require 'japan_etc/entrance_or_exit'
require 'japan_etc/error'
require 'japan_etc/road'
require 'japan_etc/route_direction'

module JapanETC
  class Tollbooth
    attr_reader :identifier, :road, :name, :entrance_or_exit, :route_direction

    def self.create(
      road_number:,
      tollbooth_number:,
      road_name:,
      route_name: nil,
      name:,
      entrance_or_exit: nil,
      route_direction: nil
    )
      identifier = Identifier.new(road_number, tollbooth_number)
      road = Road.new(road_name, route_name)
      new(identifier, road, name, entrance_or_exit, route_direction)
    end

    def initialize(identifier, road, name, entrance_or_exit = nil, route_direction = nil)
      raise ValidationError if identifier.nil? || road.nil? || name.nil?

      @identifier = identifier
      @road = road
      @name = name
      @entrance_or_exit = entrance_or_exit
      @route_direction = route_direction
    end

    Identifier = Struct.new(:road_number, :tollbooth_number) do
      def initialize(*)
        super
        raise ValidationError, '#road_number cannot be nil' if road_number.nil?
        raise ValidationError, '#tollbooth_number cannot be nil' if tollbooth_number.nil?
      end
    end
  end
end
