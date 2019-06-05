# frozen_string_literal: true

module JapanETC
  module DatabaseProvider
    class Base
      def self.inherited(subclass)
        all << subclass
      end

      def self.all
        @all ||= []
      end

      def fetch_tollbooths
        raise NotImplementedError
      end
    end
  end
end
