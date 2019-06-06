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
      @name = name.sub(/(?<head>.+?)?\s*[（\(](?<note>.+?)[）\)]\s*(?<tail>.+)?/) do
        match = Regexp.last_match

        if match[:head]
          prepend_to_notes(match[:tail]) if match[:tail]
          prepend_to_notes(match[:note])
          match[:head]
        elsif match[:tail]
          prepend_to_notes(match[:note])
          match[:tail]
        else
          match[:note]
        end
      end
    end

    def extract_direction_from_notes!
      notes.reject! do |note|
        found_direction = Direction.from(note)
        next false unless found_direction

        if direction
          raise ValidationError unless found_direction == direction
        else
          @direction = found_direction
        end

        true
      end
    end

    def extract_entrance_or_exit_from_notes!
      notes.reject! do |note|
        found_entrance_or_exit = EntranceOrExit.from(note)
        next false unless found_entrance_or_exit

        if entrance_or_exit
          raise ValidationError unless found_entrance_or_exit == entrance_or_exit
        else
          @entrance_or_exit = found_entrance_or_exit
        end

        true
      end
    end

    def extract_direction_from_name!
      name.sub!(/(?:上り|下り)/) do |match|
        found_direction = Direction.from(match)

        if direction
          found_direction == direction ? '' : match
        else
          @direction = found_direction
          ''
        end
      end
    end

    def extract_entrance_or_exit_from_name!
      name.sub!(/(?:入口|出口|料金所)/) do |match|
        found_entrance_or_exit = EntranceOrExit.from(match)
        found_entrance_or_exit ||= EntranceOrExit::EXIT

        if entrance_or_exit
          found_entrance_or_exit == entrance_or_exit ? '' : match
        else
          @entrance_or_exit = found_entrance_or_exit
          ''
        end
      end
    end

    def prepend_to_notes(note)
      note = normalize(note)
      notes.prepend(note)
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
