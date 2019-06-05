# frozen_string_literal: true

require 'japan_etc/database_provider/base'
require 'japan_etc/tollbooth'
require 'japan_etc/util'
require 'faraday'
require 'pdf-reader'

module JapanETC
  module DatabaseProvider
    # https://highwaypost.c-nexco.co.jp/faq/etc/use/50.html
    class CentralNEXCO < Base
      URL = 'https://highwaypost.c-nexco.co.jp/faq/etc/use/documents/190423-2etcriyoukanouic.pdf'

      TOLLBOOTH_LINE_PATTERN = /
        \A
        (?:
          \s{,10}(?<road_name>[^\d\s（【]\S*)\s+
          |
          \s{,10}(?:[（【]\S+)\s+ # Obsolete road name
          |
          \s{10,}
        )
        (?:
          (?<tollbooth_name>[^\d\s（【]\S*)
          \s+
        )?
        (?<identifiers>\d{2}\s+\d{3}\b.*)
      /x.freeze

      IDENTIFIER_PATTERN = /\b(\d{2})\s+(\d{3})\b/.freeze

      attr_reader :current_road_name, :current_tollbooth_name

      def fetch_tollbooths
        lines.flat_map { |line| parse_line(line) }.compact
      end

      def parse_line(line)
        match = line.match(TOLLBOOTH_LINE_PATTERN)
        return unless match

        @current_road_name = match[:road_name] if match[:road_name]

        @current_tollbooth_name = match[:tollbooth_name] if match[:tollbooth_name]

        identifiers = match[:identifiers].scan(IDENTIFIER_PATTERN)

        identifiers.map do |identifier|
          Tollbooth.create(
            road_number: Util.parse_integer_string(identifier.first),
            tollbooth_number: Util.parse_integer_string(identifier.last),
            road_name: current_road_name,
            name: current_tollbooth_name
          )
        end
      end

      def lines
        pdf.pages.flat_map { |page| page.text.each_line.to_a }
      end

      def pdf
        response = Faraday.get(URL)
        PDF::Reader.new(StringIO.new(response.body))
      end
    end
  end
end
