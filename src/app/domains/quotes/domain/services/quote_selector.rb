module Quotes
  module Domain
    module Services
      class QuoteSelector
        class EmptyQuotesError < StandardError; end

        def self.select!(date:, quotes:)
          raise EmptyQuotesError, "quotes is empty" if quotes.empty?

          index = date.yday % quotes.count
          quotes.fetch(index)
        end
      end
    end
  end
end
