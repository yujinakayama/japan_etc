# frozen_string_literal: true

require 'japan_etc/database_provider/metropolitan_expressway'

module JapanETC
  RSpec.describe DatabaseProvider::MetropolitanExpressway do
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

      it 'downloads CSV file from shutoko.jp and parses it' do
        expect(find_tollbooth(12, 583)).to have_attributes(
          road: an_object_having_attributes(name: '首都高速道路', route_name: '11号台場線'),
          name: '台場',
          entrance_or_exit: :exit,
          route_direction: nil
        )
      end
    end
  end
end