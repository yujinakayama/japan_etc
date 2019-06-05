# frozen_string_literal: true

require 'japan_etc/database'

module JapanETC
  RSpec.describe Database, vcr: { cassette_name: Database } do
    subject(:database) do
      described_class.new
    end

    describe '#tollbooths' do
      subject(:tollbooths) do
        database.tollbooths
      end

      it "doesn't include duplications" do
        tollbooths_by_identifier = tollbooths.group_by(&:identifier)
        expect(tollbooths_by_identifier.values).to all have_attributes(size: 1)
      end
    end
  end
end
