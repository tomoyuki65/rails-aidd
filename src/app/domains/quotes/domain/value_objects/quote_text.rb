module Quotes
  module Domain
    module ValueObjects
      class QuoteText
        VALID_FORMAT = /\A[ぁ-んァ-ヶ一-龥ー。、]+\z/

        attr_reader :value

        def initialize(value)
          raise ArgumentError, "QuoteText must be a String" unless value.is_a?(String)
          raise ArgumentError, "QuoteText is invalid" unless VALID_FORMAT.match?(value)

          @value = value
        end
      end
    end
  end
end
