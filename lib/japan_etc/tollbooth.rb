# frozen_string_literal: true

require 'japan_etc/entrance_or_exit'
require 'japan_etc/error'
require 'japan_etc/road'
require 'japan_etc/route_direction'
require 'japan_etc/util'

module JapanETC
  class Tollbooth
    attr_reader :identifier, :road, :name, :entrance_or_exit, :route_direction, :note

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

      extract_note_from_name!
      extract_route_direction_from_note!
    end

    def ==(other)
      other.is_a?(self.class) && identifier == other.identifier
    end

    alias eql? ==

    def hash
      identifier.hash
    end

    def to_a
      [identifier.to_a, road.to_a, name, entrance_or_exit, route_direction, note].flatten
    end

    def normalize(string)
      Util.convert_fullwidth_characters_to_halfwidth(string)
    end

    def extract_note_from_name!
      @name = name.sub(/(?<head>.+?)?（(?<note>.+?)）(?<tail>.+)?/) do
        match = Regexp.last_match

        if match[:head] || match[:tail]
          @note = match[:note]
          "#{match[:head]}#{match[:tail]}"
        else
          match[:note]
        end
      end
    end

    def extract_route_direction_from_note!
      return if route_direction

      @route_direction = RouteDirection.from(note)
      @note = nil if route_direction
    end

    Identifier = Struct.new(:road_number, :tollbooth_number) do
      include Util

      def initialize(road_number, tollbooth_number)
        road_number = convert_to_integer(road_number)
        raise ValidationError, '#road_number cannot be nil' if road_number.nil?

        tollbooth_number = convert_to_integer(tollbooth_number)
        raise ValidationError, '#tollbooth_number cannot be nil' if tollbooth_number.nil?

        super(road_number, tollbooth_number)
      end
    end
  end
end
