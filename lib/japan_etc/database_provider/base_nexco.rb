# frozen_string_literal: true

require 'japan_etc/database_provider/base'
require 'japan_etc/tollbooth'
require 'japan_etc/util'
require 'faraday'
require 'pdf-reader'

module JapanETC
  module DatabaseProvider
    class BaseNEXCO < Base
      include Util

      WHITESPACE = /[\s　]/.freeze

      ROAD_NAME_PATTERN = /
        (?<road_name>
          [^#{WHITESPACE}\d（【]
          (?:
            (?:
              (?<!連絡道)
              #{WHITESPACE}
            )?
            [^#{WHITESPACE}]
          )*
        )
      /x.freeze

      TOLLBOOTH_LINE_PATTERN = /
        \A
        (?:
          #{WHITESPACE}{,10}#{ROAD_NAME_PATTERN}#{WHITESPACE}+
          |
          #{WHITESPACE}{,10}(?:[（【][^#{WHITESPACE}]+)#{WHITESPACE}+ # Obsolete road name
          |
          #{WHITESPACE}{10,}
        )
        (?:
          (?<tollbooth_name>[^#{WHITESPACE}\d（【](?:#{WHITESPACE}?[^#{WHITESPACE}])*)
          #{WHITESPACE}+
        )?
        (?<identifiers>\d{2}#{WHITESPACE}+\d{3}\b.*?)
        (?:
          ※
          (?<note>.+?)
          #{WHITESPACE}*
        )?
        \z
      /x.freeze

      IDENTIFIER_PATTERN = /\b(\d{2})#{WHITESPACE}+(\d{3})\b/.freeze

      attr_reader :current_road_name, :current_route_name, :current_tollbooth_name

      def url
        raise NotImplementedError
      end

      def fetch_tollbooths
        tollbooths = []

        lines.each do |line|
          break if line.include?('【更新リスト】')

          tollbooths << parse_line(line)
        end

        tollbooths.flatten.compact
      end

      def parse_line(line)
        match = line.match(TOLLBOOTH_LINE_PATTERN)
        return unless match

        if match[:road_name]
          road_name = remove_whitespaces(normalize(match[:road_name]))
          @current_road_name, @current_route_name = extract_route_name_from_road_name(road_name)
          @current_road_name = canonicalize(@current_road_name)
        end

        @current_tollbooth_name = match[:tollbooth_name] if match[:tollbooth_name]

        identifiers = match[:identifiers].scan(IDENTIFIER_PATTERN)

        identifiers.map do |identifier|
          Tollbooth.create(
            road_number: identifier.first,
            tollbooth_number: identifier.last,
            road_name: current_road_name,
            route_name: current_route_name,
            name: current_tollbooth_name,
            note: match[:note]
          )
        end
      end

      def extract_route_name_from_road_name(road_name)
        road_name = normalize(road_name)
        match = road_name.match(/\A(?<road_name>.+?)(?<route_name>\d+号.+)?\z/)
        road_name = match[:road_name].sub(/高速\z/, '高速道路')
        [road_name, match[:route_name]]
      end

      def canonicalize(road_name)
        road_name = '首都圏中央連絡自動車道' if road_name == '首都圏中央連絡道'
        road_name = road_name.sub(/高速\z/, '高速道路')
        road_name
      end

      def lines
        pdf.pages.flat_map { |page| page.text.each_line.map(&:chomp).to_a }
      end

      def pdf
        response = Faraday.get(url)
        PDF::Reader.new(StringIO.new(response.body))
      end
    end
  end
end
