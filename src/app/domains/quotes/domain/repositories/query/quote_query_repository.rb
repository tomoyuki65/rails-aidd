module Quotes
  module Domain
    module Repositories
      module Query
        class QuoteQueryRepository
          def all_ordered_by_id_asc
            raise NotImplementedError
          end
        end
      end
    end
  end
end
