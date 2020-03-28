# frozen_string_literal: true

require 'japan_etc/database_provider/base_nexco'

module JapanETC
  module DatabaseProvider
    class NEXCOWest < BaseNEXCO
      def url
        'https://www.w-nexco.co.jp/etc/maintenance/pdfs/list01.pdf'
      end
    end
  end
end
