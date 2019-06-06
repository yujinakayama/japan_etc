# frozen_string_literal: true

require 'japan_etc/database_provider/hanshin_expressway'

module JapanETC
  RSpec.describe DatabaseProvider::HanshinExpressway, vcr: { cassette_name: DatabaseProvider::HanshinExpressway } do
    subject(:database_provider) do
      described_class.new
    end

    describe '#fetch_tollbooths' do
      subject(:tollbooths) do
        database_provider.fetch_tollbooths
      end

      def find_tollbooth(road_number, tollbooth_number)
        target_identifier = Tollbooth::Identifier.new(road_number, tollbooth_number)
        tollbooths.find { |tollbooth| tollbooth.identifier == target_identifier }
      end

      it 'downloads Excel file from hanshin-exp.co.jp and parses it' do
        expect(find_tollbooth(13, 102)).to have_attributes(
          road: an_object_having_attributes(name: '阪神高速道路', route_name: '1号環状線'),
          name: '四ツ橋',
          direction: nil,
          entrance_or_exit: '入口'
        )

        expect(find_tollbooth(13, 687)).to have_attributes(
          road: an_object_having_attributes(name: '阪神高速道路', route_name: '8号京都線'),
          name: '鴨川東',
          direction: nil,
          entrance_or_exit: '出口'
        )
      end

      it 'does not confuse place name ending with "出" as exit' do
        expect(find_tollbooth(13, 255)).to have_attributes(
          road: an_object_having_attributes(name: '阪神高速道路', route_name: '15号堺線'),
          name: '玉出',
          direction: nil,
          entrance_or_exit: '入口'
        )
      end

      it 'handles tollbooth names suffixed with both direction and entrance/exit like "岸和田北南行出"' do
        expect(find_tollbooth(13, 639)).to have_attributes(
          road: an_object_having_attributes(name: '阪神高速道路', route_name: '4号湾岸線'),
          name: '岸和田北',
          direction: '南行き',
          entrance_or_exit: '出口'
        )
      end
    end
  end
end
