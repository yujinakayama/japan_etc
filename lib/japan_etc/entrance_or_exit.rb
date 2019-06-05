# frozen_string_literal: true

module JapanETC
  module EntranceOrExit
    ENTRANCE = :entrance
    EXIT     = :exit

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
