# frozen_string_literal: true

require 'japan_etc/database_provider/base_nexco'

module JapanETC
  module DatabaseProvider
    class NEXCOCentral < BaseNEXCO
      def source_url
        'https://highwaypost.c-nexco.co.jp/faq/etc/use/documents/etcriyoukanouic.pdf'
      end
    end
  end
end
