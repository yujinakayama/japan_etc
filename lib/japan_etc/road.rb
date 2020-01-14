# frozen_string_literal: true

require 'japan_etc/error'
require 'japan_etc/util'

module JapanETC
  Road = Struct.new(:name, :route_name) do
    include Comparable
    include Util

    IRREGULAR_ABBREVIATIONS = {
      '東名高速道路' => '東名',
      '新東名高速道路' => '新東名',
      '名神高速道路' => '名神',
      '新名神高速道路' => '新名神',
      '首都高速道路' => '首都高',
      '首都圏中央連絡自動車道' => '圏央道',
      '東京湾アクアライン' => 'アクアライン',
      '東京湾アクアライン連絡道' => 'アクア連絡道',
      '名古屋第二環状自動車道' => '名二環'
    }

    def initialize(name, route_name = nil)
      raise ValidationError, '#name cannot be nil' if name.nil?

      super(normalize(name), normalize(route_name))
    end

    def abbreviation
      @abbreviation ||=
        if (irregular_abbreviation = IRREGULAR_ABBREVIATIONS[name])
          irregular_abbreviation
        else
          regular_abbreviation
        end
    end

    def regular_abbreviation
      abbreviation = name.dup

      if abbreviation.start_with?('第')
        abbreviation = abbreviation.sub(/高速道路|自動車道|道路/, '')
      end

      abbreviation = abbreviation
        .sub('高速道路', '高速')
        .sub('自動車道', '道')
        .sub('道路', '道')
        .sub('有料', '')

      abbreviation
    end

    def <=>(other)
      [:name, :route_name].each do |attribute|
        result = send(attribute) <=> other.send(attribute)
        return result unless result.zero?
      end

      0
    end
  end
end
