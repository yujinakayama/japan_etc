# frozen_string_literal: true

require 'japan_etc/database_provider/nexco_central'

module JapanETC
  RSpec.describe DatabaseProvider::NEXCOCentral, vcr: { cassette_name: DatabaseProvider::NEXCOCentral } do
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

      it 'handles road names properly' do
        expect(find_tollbooth(5, 20)).to have_attributes(
          road: an_object_having_attributes(
            name: '道央自動車道',
            route_name: nil
          ),
          name: '大沼公園本線'
        )

        expect(find_tollbooth(5, 985)).to have_attributes(
          road: an_object_having_attributes(
            name: '道央自動車道',
            route_name: nil
          ),
          name: '深川西本線'
        )

        expect(find_tollbooth(5, 151)).to have_attributes(
          road: an_object_having_attributes(
            name: '道東自動車道',
            route_name: nil
          ),
          name: '千歳東'
        )
      end

      it 'handles tollboothes having multiple identifiers properly' do
        expect(find_tollbooth(5, 102)).to have_attributes(
          road: an_object_having_attributes(
            name: '道央自動車道',
            route_name: nil
          ),
          name: '江別西'
        )

        expect(find_tollbooth(5, 902)).to have_attributes(
          road: an_object_having_attributes(
            name: '道央自動車道',
            route_name: nil
          ),
          name: '江別西'
        )
      end

      it 'handles tollboothes having some comment properly' do
        expect(find_tollbooth(5, 360)).to have_attributes(
          road: an_object_having_attributes(
            name: '道東自動車道',
            route_name: nil
          ),
          name: '池田'
        )
      end

      it 'ignores obsolete road names' do
        expect(find_tollbooth(7, 38)).to have_attributes(
          road: an_object_having_attributes(
            name: '三陸自動車道',
            route_name: nil
          ),
          name: '松島海岸'
        )
      end

      it 'handles tollboothes having multiple identifiers expanding multilines properly' do
        expect(find_tollbooth(6, 517)).to have_attributes(
          road: an_object_having_attributes(
            name: '近畿自動車道',
            route_name: nil
          ),
          name: '門真JCT'
        )

        expect(find_tollbooth(6, 306)).to have_attributes(
          road: an_object_having_attributes(
            name: '近畿自動車道',
            route_name: nil
          ),
          name: '門真JCT'
        )
      end

      it 'handles full-width whitespace properly' do
        expect(find_tollbooth(83, 303)).to have_attributes(
          road: an_object_having_attributes(
            name: '小田原厚木道路',
            route_name: nil
          ),
          name: '平塚本線'
        )
      end

      pending 'handles strange unextractable tollbooth numbers' do
        expect(find_tollbooth(1, 131)).to have_attributes(
          road: an_object_having_attributes(
            name: '名古屋第二環状自動車道',
            route_name: nil
          ),
          name: '名二環名古屋'
        )
      end
    end
  end
end
