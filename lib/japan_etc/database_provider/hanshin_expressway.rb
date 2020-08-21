# frozen_string_literal: true

require 'japan_etc/database_provider/base'
require 'japan_etc/tollbooth'
require 'faraday'
require 'spreadsheet'

module JapanETC
  module DatabaseProvider
    # https://www.hanshin-exp.co.jp/drivers/ryoukin/etc_ryokinsyo/
    class HanshinExpressway < Base
      def source_url
        'https://www.hanshin-exp.co.jp/drivers/ryoukin/files/code_20200329.xls'
      end

      def fetch_tollbooths
        rows.flat_map do |row|
          process_row(row)
        end.compact
      end

      def process_row(row)
        route_name, road_number, tollbooth_number, tollbooth_name, _, note = row

        return nil if !road_number.is_a?(Numeric) || !tollbooth_number.is_a?(Numeric)

        tollbooth = Tollbooth.create(
          road_number: road_number,
          tollbooth_number: tollbooth_number,
          road_name: '阪神高速道路',
          route_name: route_name,
          name: tollbooth_name,
          note: note,
          source: source_id
        )

        remove_redundant_name_suffix!(tollbooth)

        tollbooth
      end

      def remove_redundant_name_suffix!(tollbooth)
        return unless tollbooth.entrance_or_exit

        tollbooth.name.sub!(/[入出]\z/) do |match|
          found_entrance_or_exit = EntranceOrExit.from(match)
          found_entrance_or_exit == tollbooth.entrance_or_exit ? '' : match
        end
      end

      def rows
        workbook.worksheets.first.rows
      end

      def workbook
        response = Faraday.get(source_url)
        Spreadsheet.open(StringIO.new(response.body))
      end
    end
  end
end
