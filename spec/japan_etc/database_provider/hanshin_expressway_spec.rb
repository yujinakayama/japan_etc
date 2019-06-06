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
          entrance_or_exit: nil
        )

        expect(find_tollbooth(13, 687)).to have_attributes(
          road: an_object_having_attributes(name: '阪神高速道路', route_name: '8号京都線'),
          name: '鴨川東出',
          direction: nil,
          entrance_or_exit: nil
        )
      end
    end
  end
end
