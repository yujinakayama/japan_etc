# frozen_string_literal: true

module JapanETC
  module Util
    module_function

    def parse_integer_string(string)
      Integer(string.sub(/\A0+/, ''))
    end
  end
end
