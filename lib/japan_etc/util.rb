# frozen_string_literal: true

module JapanETC
  module Util
    module_function

    def convert_fullwidth_characters_to_halfwidth(string)
      return nil unless string

      string.tr('Ａ-Ｚａ-ｚ０-９', 'A-Za-z0-9')
    end

    def parse_integer_string(string)
      Integer(string.sub(/\A0+/, ''))
    end
  end
end
