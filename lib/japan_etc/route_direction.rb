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
      when '上り', '上'
        INBOUND
      when '下り', '下'
        OUTBOUND
      when '外回り', '外'
        CLOCKWISE
      when '内回り', '内'
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
