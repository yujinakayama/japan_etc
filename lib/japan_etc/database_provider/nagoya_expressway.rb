# frozen_string_literal: true

require 'japan_etc/database_provider/base'
require 'japan_etc/tollbooth'
require 'faraday'
require 'nokogiri'

module JapanETC
  module DatabaseProvider
    # http://www.nagoya-expressway.or.jp/etc/etc-lane.html
    class NagoyaExpressway < Base
      URL = 'http://www.nagoya-expressway.or.jp/etc/etc-lane.html'

      def fetch_tollbooths
        rows.map do |row|
          begin
            road_number = Integer(row[4])
            tollbooth_number = Integer(row[5])
          rescue ArgumentError, TypeError
            next
          end

          Tollbooth.create(
            road_number: road_number,
            tollbooth_number: tollbooth_number,
            road_name: '名古屋高速道路',
            route_name: row[0],
            name: row[2]
          )
        end.compact
      end

      def rows
        raw_rows.each_with_object([]).map do |tr, pending_subsequent_rows|
          current_row = pending_subsequent_rows.shift || Row.new

          tr.css('td,th').each_with_index do |td, column_index|
            text = td.text.tr(' ', '')
            current_row[column_index] = text

            next unless td.attr('rowspan')

            subsequent_row_count = Integer(td.attr('rowspan')) - 1

            (0...subsequent_row_count).each do |row_index|
              subsequent_row = (pending_subsequent_rows[row_index] ||= Row.new)
              subsequent_row[column_index] = text
            end
          end

          current_row.to_a
        end
      end

      def raw_rows
        doc.css('tr')
      end

      def doc
        response = Faraday.get(URL)
        Nokogiri(response.body)
      end

      class Row
        def [](index)
          array[index]
        end

        def []=(index, element)
          index += 1 until array[index].nil?
          array[index] = element
        end

        def array
          @array ||= []
        end

        alias to_a array
      end
    end
  end
end
