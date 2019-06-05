# frozen_string_literal: true

module JapanETC
  module DatabaseProvider
    class Base
      def fetch_tollbooths
        raise NotImplementedError
      end
    end
  end
end
