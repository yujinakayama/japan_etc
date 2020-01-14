# frozen_string_literal: true

require 'japan_etc/entrance_or_exit'
require 'japan_etc/error'
require 'japan_etc/road'
require 'japan_etc/direction'
require 'japan_etc/util'

module JapanETC
  class Tollbooth
    include Comparable
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

      normalize!
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

    def <=>(other)
      result = identifier <=> other.identifier
      return result unless result.zero?

      return -1 if !obsolete? && other.obsolete?
      return 1 if obsolete? && !other.obsolete?

      [:road, :name].each do |attribute|
        result = send(attribute) <=> other.send(attribute)
        return result unless result.zero?
      end

      0
    end

    def to_a
      [
        identifier.to_s,
        road.to_a,
        name,
        direction,
        entrance_or_exit,
        notes.empty? ? nil : notes.join(' ')
      ].flatten
    end

    def obsolete?
      notes.any? { |note| note.include?('迄') }
    end

    private

    def normalize!
      extract_notes_from_name!
      extract_direction_from_notes!
      extract_entrance_or_exit_from_notes!
      extract_direction_from_name!
      extract_entrance_or_exit_from_name!
      name_was_changed = extract_name_from_notes!
      normalize! if name_was_changed
    end

    def extract_notes_from_name!
      name.sub!(/(?<head>.+?)?\s*[（\(](?<note>.+?)[）\)]\s*(?<tail>.+)?/) do
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

      name.sub!(/第[一二三]\z/) do |match|
        prepend_to_notes(match)
        ''
      end

      name.sub!(/合併\z/) do |match|
        prepend_to_notes(match) unless notes.any? { |note| note.include?('合併') }
        ''
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
      name.sub!(/(?:上り|下り|[東西南北]行き?)/) do |match|
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

    def extract_name_from_notes!
      name_was_changed = notes.reject! do |note|
        match = note.match(/「(?<new_name>.+?)」へ名称変更/)
        next false unless match

        @name = normalize(match[:new_name])

        true
      end

      name_was_changed
    end

    def prepend_to_notes(note)
      note = normalize(note)
      notes.prepend(note)
    end

    Identifier = Struct.new(:road_number, :tollbooth_number) do
      include Comparable
      include Util

      def initialize(road_number, tollbooth_number)
        road_number = convert_to_integer(road_number)
        raise ValidationError, '#road_number cannot be nil' if road_number.nil?
        raise ValidationError, '#road_number must be lower than 100' if road_number >= 100

        tollbooth_number = convert_to_integer(tollbooth_number)
        raise ValidationError, '#tollbooth_number cannot be nil' if tollbooth_number.nil?
        raise ValidationError, '#road_number must be lower than 1000' if tollbooth_number >= 1000

        super(road_number, tollbooth_number)
      end

      def to_s
        @string ||= format('%02d-%03d', road_number, tollbooth_number)
      end

      def <=>(other)
        to_s <=> other.to_s
      end
    end
  end
end
