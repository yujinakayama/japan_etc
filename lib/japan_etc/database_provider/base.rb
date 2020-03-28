# frozen_string_literal: true

require 'addressable'

module JapanETC
  module DatabaseProvider
    class Base
      def source_url
        raise NotImplementedError
      end

      def source_id
        @source_id ||= Addressable::URI.parse(source_url).domain
      end

      def fetch_tollbooths
        raise NotImplementedError
      end
    end
  end
end
