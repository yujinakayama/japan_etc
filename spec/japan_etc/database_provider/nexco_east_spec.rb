# frozen_string_literal: true

require 'japan_etc/database_provider/nexco_east'

module JapanETC
  RSpec.describe DatabaseProvider::NEXCOEast, vcr: { cassette_name: DatabaseProvider::NEXCOEast } do
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

      it 'handles road names including superfluous whitespaces properly' do
        expect(find_tollbooth(4, 48)).to have_attributes(
          road: an_object_having_attributes(
            name: '首都圏中央連絡自動車道',
            route_name: nil
          ),
          name: '茅ヶ崎JCT'
        )

        expect(find_tollbooth(4, 850)).to have_attributes(
          road: an_object_having_attributes(
            name: '新名神高速道路',
            route_name: nil
          ),
          name: '菰野'
        )

        expect(find_tollbooth(3, 52)).to have_attributes(
          road: an_object_having_attributes(
            name: '東京湾アクアライン連絡道',
            route_name: nil
          ),
          name: '木更津金田'
        )
      end
    end
  end
end
