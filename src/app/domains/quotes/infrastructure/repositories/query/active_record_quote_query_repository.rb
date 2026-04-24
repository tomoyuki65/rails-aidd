module Quotes
  module Infrastructure
    module Repositories
      module Query
        class ActiveRecordQuoteQueryRepository < Quotes::Domain::Repositories::Query::QuoteQueryRepository
          def all_ordered_by_id_asc
            Quote.order(:id).map do |record|
              Quotes::Domain::Entities::Quote.new(
                id: record.id,
                quote_text: Quotes::Domain::ValueObjects::QuoteText.new(record.text)
              )
            end
          end
        end
      end
    end
  end
end
