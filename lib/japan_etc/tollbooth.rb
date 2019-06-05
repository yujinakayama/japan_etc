# frozen_string_literal: true

require 'japan_etc/entrance_or_exit'
require 'japan_etc/error'
require 'japan_etc/road'
require 'japan_etc/direction'
require 'japan_etc/util'

module JapanETC
  class Tollbooth
    include Util

    attr_accessor :identifier, :road, :name, :entrance_or_exit, :direction, :notes

    def self.create(
      road_number:,
      tollbooth_number:,
      road_name:,
      route_name: nil,
      name:,
      direction: nil,
      entrance_or_exit: nil,
      note: nil
    )
      identifier = Identifier.new(road_number, tollbooth_number)
      road = Road.new(road_name, route_name)
      new(identifier, road, name, direction, entrance_or_exit, note)
    end

    def initialize(identifier, road, name, direction = nil, entrance_or_exit = nil, note = nil) # rubocop:disable Metrics/LineLength
      raise ValidationError if identifier.nil? || road.nil? || name.nil?

      @identifier = identifier
      @road = road
      @name = normalize(name)
      @direction = direction
      @entrance_or_exit = entrance_or_exit
      @notes = []
      notes << normalize(note) if note

      extract_note_from_name!
      extract_direction_from_notes!
      extract_entrance_or_exit_from_notes!
      extract_direction_from_name!
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
        direction,
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

    def extract_direction_from_notes!
      return if direction

      notes.reject! do |note|
        next false if direction

        @direction = Direction.from(note)
      end
    end

    def extract_entrance_or_exit_from_notes!
      return if entrance_or_exit

      notes.reject! do |note|
        next false if entrance_or_exit

        @entrance_or_exit = EntranceOrExit.from(note)
      end
    end

    def extract_direction_from_name!
      return if direction

      name.sub!(/(?:上り|下り)/) do |match|
        @direction = match == '上り' ? Direction::INBOUND : Direction::OUTBOUND
        ''
      end
    end

    def extract_entrance_or_exit_from_name!
      return if entrance_or_exit

      name.sub!(/(?:入口|料金所)/) do |match|
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
