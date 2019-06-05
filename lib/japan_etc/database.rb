# frozen_string_literal: true

require 'japan_etc/database_provider'
require 'csv'

module JapanETC
  class Database
    def tollbooths
      @tollbooths ||= providers.map(&:fetch_tollbooths).flatten.uniq
    end

    def save_as_csv(filename: 'database/japan_etc_tollbooths.csv')
      CSV.open(filename, 'w') do |csv|
        tollbooths.each { |tollbooth| csv << tollbooth.to_a }
      end
    end

    def providers
      DatabaseProvider::Base.all.map(&:new)
    end
  end
end
