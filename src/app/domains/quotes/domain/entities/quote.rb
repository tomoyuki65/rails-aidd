module Quotes
  module Domain
    module Entities
      class Quote
        attr_reader :id, :quote_text

        def initialize(id:, quote_text:)
          @id = id
          @quote_text = quote_text
        end
      end
    end
  end
end
