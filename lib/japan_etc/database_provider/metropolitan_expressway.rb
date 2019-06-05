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

      def fetch_tollbooths
        rows.map do |row|
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
