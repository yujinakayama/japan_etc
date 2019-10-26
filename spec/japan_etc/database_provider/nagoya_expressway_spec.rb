# frozen_string_literal: true

require 'japan_etc/database_provider/nagoya_expressway'

module JapanETC
  RSpec.describe DatabaseProvider::NagoyaExpressway, vcr: { cassette_name: DatabaseProvider::NagoyaExpressway } do
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

      it 'handles columns with rowspan attribute' do
        expect(find_tollbooth(41, 145)).to have_attributes(
          road: an_object_having_attributes(name: '名古屋高速道路', route_name: '都心環状線'),
          name: '丸の内',
          direction: nil,
          entrance_or_exit: '出口'
        )

        expect(find_tollbooth(41, 611)).to have_attributes(
          road: an_object_having_attributes(name: '名古屋高速道路', route_name: '1号楠線'),
          name: '楠',
          direction: nil,
          entrance_or_exit: nil
        )

        expect(find_tollbooth(41, 612)).to have_attributes(
          road: an_object_having_attributes(name: '名古屋高速道路', route_name: '1号楠線'),
          name: '楠',
          direction: nil,
          entrance_or_exit: nil
        )

        expect(find_tollbooth(41, 613)).to have_attributes(
          road: an_object_having_attributes(name: '名古屋高速道路', route_name: '1号楠線'),
          name: '楠',
          direction: nil,
          entrance_or_exit: '入口'
        )
      end
    end
  end
end
