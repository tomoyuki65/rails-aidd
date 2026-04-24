module Quotes
  module UseCases
    class FetchDailyQuote
      Result = Struct.new(:quote, :jst_date, :history_key_date, keyword_init: true)

      def initialize(
        quote_query_repository: Quotes::Infrastructure::Repositories::Query::ActiveRecordQuoteQueryRepository.new,
        quote_history_query_repository: Quotes::Infrastructure::Repositories::Query::ActiveRecordQuoteHistoryQueryRepository.new,
        quote_history_command_repository: Quotes::Infrastructure::Repositories::Command::ActiveRecordQuoteHistoryCommandRepository.new
      )
        @quote_query_repository = quote_query_repository
        @quote_history_query_repository = quote_history_query_repository
        @quote_history_command_repository = quote_history_command_repository
      end

      def call
        jst_zone = Time.find_zone!("Asia/Tokyo")
        jst_date = jst_zone.today
        history_key_date = jst_zone.local(jst_date.year, jst_date.month, jst_date.day).utc.to_date

        quotes = @quote_query_repository.all_ordered_by_id_asc
        quote_id = @quote_history_query_repository.find_quote_id_by_date(date: history_key_date)
        return Result.new(quote: find_quote_by_id!(quotes, quote_id), jst_date:, history_key_date:) if quote_id

        selected_quote = Quotes::Domain::Services::QuoteSelector.select!(date: jst_date, quotes:)

        begin
          @quote_history_command_repository.create!(date: history_key_date, quote_id: selected_quote.id)
        rescue Quotes::Domain::Repositories::Command::QuoteHistoryCommandRepository::AlreadyExistsError
          nil
        end

        stored_quote_id = @quote_history_query_repository.find_quote_id_by_date(date: history_key_date)
        raise "quote_history not found after insert" unless stored_quote_id

        Result.new(quote: find_quote_by_id!(quotes, stored_quote_id), jst_date:, history_key_date:)
      end

      private

      def find_quote_by_id!(quotes, quote_id)
        quotes.find { |quote| quote.id == quote_id } || raise("quote not found: #{quote_id}")
      end
    end
  end
end
