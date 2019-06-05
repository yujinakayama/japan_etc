# frozen_string_literal: true

module JapanETC
  module EntranceOrExit
    ENTRANCE = '入口'
    EXIT     = '出口'

    def self.from(text)
      case text
      when '入口'
        ENTRANCE
      when '出口'
        EXIT
      end
    end
  end
end
