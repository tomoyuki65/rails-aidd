module Quotes
  module Infrastructure
    module Repositories
      module Query
        class ActiveRecordQuoteHistoryQueryRepository < Quotes::Domain::Repositories::Query::QuoteHistoryQueryRepository
          def find_quote_id_by_date(date:)
            QuoteHistory.find_by(date:)&.quote_id
          end
        end
      end
    end
  end
end
