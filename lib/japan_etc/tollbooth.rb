# frozen_string_literal: true

require 'japan_etc/entrance_or_exit'
require 'japan_etc/error'
require 'japan_etc/road'
require 'japan_etc/route_direction'
require 'japan_etc/util'

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
      @name = normalize(name)
      @entrance_or_exit = entrance_or_exit
      @route_direction = route_direction
    end

    def ==(other)
      other.is_a?(self.class) && identifier == other.identifier
    end

    alias eql? ==

    def hash
      identifier.hash
    end

    def to_a
      [identifier.to_a, road.to_a, name, entrance_or_exit, route_direction].flatten
    end

    def normalize(string)
      Util.convert_fullwidth_characters_to_halfwidth(string)
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
