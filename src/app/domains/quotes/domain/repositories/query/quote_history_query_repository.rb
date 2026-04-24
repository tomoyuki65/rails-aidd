module Quotes
  module Domain
    module Repositories
      module Query
        class QuoteHistoryQueryRepository
          def find_quote_id_by_date(date:)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
