# frozen_string_literal: true

require 'japan_etc/entrance_or_exit'
require 'japan_etc/error'
require 'japan_etc/road'
require 'japan_etc/route_direction'
require 'japan_etc/util'

module JapanETC
  class Tollbooth
    include Util

    attr_accessor :identifier, :road, :name, :entrance_or_exit, :route_direction, :notes

    def self.create(
      road_number:,
      tollbooth_number:,
      road_name:,
      route_name: nil,
      name:,
      route_direction: nil,
      entrance_or_exit: nil,
      note: nil
    )
      identifier = Identifier.new(road_number, tollbooth_number)
      road = Road.new(road_name, route_name)
      new(identifier, road, name, route_direction, entrance_or_exit, note)
    end

    def initialize(identifier, road, name, route_direction = nil, entrance_or_exit = nil, note = nil) # rubocop:disable Metrics/LineLength
      raise ValidationError if identifier.nil? || road.nil? || name.nil?

      @identifier = identifier
      @road = road
      @name = normalize(name)
      @route_direction = route_direction
      @entrance_or_exit = entrance_or_exit
      @notes = []
      notes << normalize(note) if note

      extract_note_from_name!
      extract_route_direction_from_notes!
      extract_entrance_or_exit_from_notes!
      extract_entrance_or_exit_from_name!
    end

    def initialize_copy(original)
      @road = original.road.dup
      @name = original.name.dup
    end

    def ==(other)
      other.is_a?(self.class) && identifier == other.identifier
    end

    alias eql? ==

    def hash
      identifier.hash
    end

    def to_a
      [
        identifier.to_a,
        road.to_a,
        name,
        route_direction,
        entrance_or_exit,
        notes.empty? ? nil : notes.join(' ')
      ].flatten
    end

    def extract_note_from_name!
      @name = name.sub(/(?<head>.+?)?（(?<note>.+?)）(?<tail>.+)?/) do
        match = Regexp.last_match

        if match[:head] || match[:tail]
          notes.prepend(match[:note])
          "#{match[:head]}#{match[:tail]}"
        else
          match[:note]
        end
      end
    end

    def extract_route_direction_from_notes!
      return if route_direction

      notes.reject! do |note|
        next false if route_direction

        @route_direction = RouteDirection.from(note)
      end
    end

    def extract_entrance_or_exit_from_notes!
      return if entrance_or_exit

      notes.reject! do |note|
        next false if entrance_or_exit

        @entrance_or_exit = EntranceOrExit.from(note)
      end
    end

    def extract_entrance_or_exit_from_name!
      return if entrance_or_exit

      name.sub!(/(?:入口|料金所)\z/) do |match|
        @entrance_or_exit = match == '入口' ? EntranceOrExit::ENTRANCE : EntranceOrExit::EXIT
        ''
      end
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
