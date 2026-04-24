module Quotes
  module Infrastructure
    module Repositories
      module Command
        class ActiveRecordQuoteHistoryCommandRepository < Quotes::Domain::Repositories::Command::QuoteHistoryCommandRepository
          def create!(date:, quote_id:)
            QuoteHistory.create!(date:, quote_id:)
          rescue ActiveRecord::RecordNotUnique
            raise Quotes::Domain::Repositories::Command::QuoteHistoryCommandRepository::AlreadyExistsError
          end
        end
      end
    end
  end
end
