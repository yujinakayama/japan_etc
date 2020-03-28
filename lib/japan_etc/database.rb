# frozen_string_literal: true

require 'japan_etc/database_provider/hanshin_expressway'
require 'japan_etc/database_provider/metropolitan_expressway'
require 'japan_etc/database_provider/nagoya_expressway'
require 'japan_etc/database_provider/nexco_central'
require 'japan_etc/database_provider/nexco_east'
require 'japan_etc/database_provider/nexco_west'
require 'japan_etc/database_provider/past_database'
require 'csv'

module JapanETC
  class Database
    CSV_HEADER = %i[
      tollbooth_id
      road_name
      route_name
      tollbooth_name
      direction
      entrance_or_exit
      notes
      source
    ].freeze

    PROVIDER_CLASSES = [
      DatabaseProvider::HanshinExpressway,
      DatabaseProvider::MetropolitanExpressway,
      DatabaseProvider::NagoyaExpressway,
      DatabaseProvider::NEXCOCentral,
      DatabaseProvider::NEXCOEast,
      DatabaseProvider::NEXCOWest,
      DatabaseProvider::PastDatabase
    ].freeze

    def roads
      tollbooths.map(&:road).uniq
    end

    def tollbooths
      @tollbooths ||= providers.map(&:fetch_tollbooths).flatten.sort.uniq
    end

    def save_as_csv(filename: 'database/japan_etc_tollbooths.csv')
      CSV.open(filename, 'w') do |csv|
        csv << CSV_HEADER
        tollbooths.each { |tollbooth| csv << tollbooth.to_a }
      end
    end

    def providers
      PROVIDER_CLASSES.map(&:new)
    end
  end
end
