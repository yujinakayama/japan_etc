# frozen_string_literal: true

require 'japan_etc/database'

module JapanETC
  RSpec.describe Tollbooth do
    context 'with name including pure note' do
      subject(:tollbooth) do
        Tollbooth.create(
          road_number: 10,
          tollbooth_number: 50,
          road_name: '東京外環自動車道',
          name: '外環三郷東（2018/6/2より「三郷中央」へ名称変更）'
        )
      end

      it 'extract the note from the name' do
        expect(tollbooth).to have_attributes(
          name: '外環三郷東',
          notes: ['2018/6/2より「三郷中央」へ名称変更']
        )
      end
    end

    context 'with some sort of obsolete name in parentheses' do
      subject(:tollbooth) do
        Tollbooth.create(
          road_number: 12,
          tollbooth_number: 934,
          road_name: '首都高速道路',
          route_name: '湾岸線',
          name: '（鳥浜町本線）',
          entrance_or_exit: EntranceOrExit::ENTRANCE
        )
      end

      it 'removes only the parentheses without extracting the content as a note' do
        expect(tollbooth).to have_attributes(
          name: '鳥浜町本線',
          notes: []
        )
      end
    end

    context 'with name suffixed with "第X" with note' do
      subject(:tollbooth) do
        Tollbooth.create(
          road_number: 31,
          tollbooth_number: 57,
          road_name: '東京湾アクアライン',
          name: '木更津金田第一(木更津本線、川崎→木更津)'
        )
      end

      it 'extract to suffix from the name' do
        expect(tollbooth).to have_attributes(
          name: '木更津金田',
          notes: ['第一', '木更津本線、川崎→木更津']
        )
      end
    end
  end
end
