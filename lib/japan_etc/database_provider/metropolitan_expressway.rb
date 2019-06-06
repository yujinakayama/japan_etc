# frozen_string_literal: true

require 'japan_etc/database_provider/base'
require 'japan_etc/tollbooth'
require 'csv'
require 'faraday'

module JapanETC
  module DatabaseProvider
    # https://www.shutoko.jp/fee/tollbooth/
    class MetropolitanExpressway < Base
      URL = 'https://www.shutoko.jp/fee/tollbooth/~/media/pdf/customer/fee/tollbooth/code190201.csv/'

      OPPOSITE_DIRECTIONS = {
        '上' => '下',
        '下' => '上',
        '外' => '内',
        '内' => '外',
        '東' => '西',
        '西' => '東'
      }.freeze

      DIRECTION_SUFFIX_PATTERN = /[#{OPPOSITE_DIRECTIONS.keys.join('')}]\z/.freeze

      def fetch_tollbooths
        original_tollbooths.map do |original_tollbooth|
          tollbooth = original_tollbooth.dup
          extract_direction_from_name!(tollbooth)
          tollbooth
        end
      end

      def extract_direction_from_name!(tollbooth)
        match = tollbooth.name.match(DIRECTION_SUFFIX_PATTERN)

        return unless match

        direction = match.to_s

        return if %w[東 西].include?(direction) && tollbooth.route_name != '湾岸線'

        opposite_name = tollbooth.name.sub(DIRECTION_SUFFIX_PATTERN, OPPOSITE_DIRECTIONS[direction])

        opposite_tollbooth_exists = original_tollbooths.find do |other_tollbooth|
          other_tollbooth.route_name == tollbooth.route_name &&
            other_tollbooth.name == opposite_name
        end

        return unless opposite_tollbooth_exists

        tollbooth.direction = Direction.from(direction)
        tollbooth.name.sub!(DIRECTION_SUFFIX_PATTERN, '')
      end

      def original_tollbooths
        @original_tollbooths ||= rows.map do |row|
          Tollbooth.create(
            road_number: row[0],
            tollbooth_number: row[1],
            road_name: '首都高速道路',
            route_name: row[2],
            name: row[3],
            entrance_or_exit: EntranceOrExit.from(row[4])
          )
        end
      end

      def rows
        CSV.parse(csv, headers: :first_row)
      end

      def csv
        shiftjis_csv.encode(Encoding::UTF_8)
      end

      def shiftjis_csv
        response = Faraday.get(URL)
        response.body.force_encoding(Encoding::Shift_JIS)
      end
    end
  end
end
