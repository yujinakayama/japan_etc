# frozen_string_literal: true

module JapanETC
  module Util
    module_function

    def convert_fullwidth_characters_to_halfwidth(string)
      return nil unless string

      string.tr('Ａ-Ｚａ-ｚ０-９', 'A-Za-z0-9')
    end

    def convert_to_integer(object)
      case object
      when Integer
        object
      when String
        Integer(object.sub(/\A0+/, ''))
      else
        raise ArgumentError
      end
    end
  end
end
