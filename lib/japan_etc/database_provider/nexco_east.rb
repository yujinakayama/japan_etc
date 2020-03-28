# frozen_string_literal: true

require 'japan_etc/database_provider/base_nexco'

module JapanETC
  module DatabaseProvider
    class NEXCOEast < BaseNEXCO
      def url
        'https://www.driveplaza.com/traffic/tolls_etc/etc_area/pdf/all01.pdf'
      end
    end
  end
end
