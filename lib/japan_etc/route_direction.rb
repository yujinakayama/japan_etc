# frozen_string_literal: true

module JapanETC
  module RouteDirection
    INBOUND          = :inbound
    OUTBOUND         = :outbound
    CLOCKWISE        = :clockwise
    COUNTERCLOCKWISE = :counterclockwise
    NORTH            = :north
    SOUTH            = :south
    EAST             = :east
    WEST             = :west

    def self.from(text)
      case text
      when '上り'
        INBOUND
      when '下り'
        OUTBOUND
      when '外回り'
        CLOCKWISE
      when '内回り'
        COUNTERCLOCKWISE
      when '北'
        NORTH
      when '南'
        SOUTH
      when '東'
        EAST
      when '西'
        WEST
      end
    end
  end
end
