module Quotes
  module Domain
    module Repositories
      module Command
        class QuoteHistoryCommandRepository
          class AlreadyExistsError < StandardError; end

          def create!(date:, quote_id:)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
