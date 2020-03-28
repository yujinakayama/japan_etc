# frozen_string_literal: true

require 'japan_etc/database_provider/base'
require 'japan_etc/tollbooth'
require 'faraday'
require 'nokogiri'

module JapanETC
  module DatabaseProvider
    # http://www.nagoya-expressway.or.jp/etc/etc-lane.html
    class PastDatabase < Base
      def source_id
        'PastDatabase'
      end

      def fetch_tollbooths
        rows.map do |row|
          create_tollbooth_from_row(row)
        end
      end

      def create_tollbooth_from_row(row)
        identifier = Tollbooth::Identifier.from(row[0])

        road = Road.new(row[1], row[2])

        Tollbooth.new(
          identifier: identifier,
          road: road,
          name: row[3],
          direction: row[4],
          entrance_or_exit: row[5],
          note: row[6],
          source: source_id,
          priority: -1
        )
      end

      def rows
        CSV.parse(csv, headers: :first_row)
      end

      def csv
        path = File.join(__dir__, 'past_database.csv')
        File.read(path)
      end
    end
  end
end
