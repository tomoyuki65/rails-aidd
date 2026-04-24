require "rails_helper"

RSpec.describe Quotes::UseCases::FetchDailyQuote do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.utc(2026, 4, 22, 15, 0, 0)) { example.run } # JST: 2026-04-23 00:00
  end

  it "creates a history when missing and returns the selected quote" do
    q1 = Quote.create!(text: "一日一善。")
    q2 = Quote.create!(text: "継続は力なり。")
    q3 = Quote.create!(text: "雨降って地固まる。")

    use_case = described_class.new
    result = use_case.call

    expect(result.jst_date).to eq(Date.new(2026, 4, 23))
    expect(result.history_key_date).to eq(Date.new(2026, 4, 22))

    index = result.jst_date.yday % 3
    expected_quote = [ q1, q2, q3 ].sort_by(&:id)[index]

    expect(result.quote.id).to eq(expected_quote.id)
    expect(result.quote.quote_text.value).to eq(expected_quote.text)

    expect(QuoteHistory.count).to eq(1)
    history = QuoteHistory.first
    expect(history.date).to eq(Date.new(2026, 4, 22))
    expect(history.quote_id).to eq(expected_quote.id)
  end

  it "returns the same quote within the same day when history exists" do
    q1 = Quote.create!(text: "一日一善。")
    q2 = Quote.create!(text: "継続は力なり。")

    history_key_date = Date.new(2026, 4, 22)
    QuoteHistory.create!(date: history_key_date, quote_id: q1.id)

    use_case = described_class.new
    result = use_case.call

    expect(result.quote.id).to eq(q1.id)
    expect(result.quote.quote_text.value).to eq(q1.text)
    expect(QuoteHistory.count).to eq(1)
  end

  it "is idempotent when insert conflicts happen" do
    q1 = Quote.create!(text: "一日一善。")
    q2 = Quote.create!(text: "継続は力なり。")

    history_key_date = Date.new(2026, 4, 22)

    inner = Quotes::Infrastructure::Repositories::Command::ActiveRecordQuoteHistoryCommandRepository.new
    query = Quotes::Infrastructure::Repositories::Query::ActiveRecordQuoteHistoryQueryRepository.new

    conflict_once_command = Class.new do
      def initialize(inner:, history_key_date:, quote_id:)
        @inner = inner
        @history_key_date = history_key_date
        @quote_id = quote_id
        @called = false
      end

      def create!(date:, quote_id:)
        return @inner.create!(date:, quote_id:) if @called

        @called = true
        QuoteHistory.create!(date: @history_key_date, quote_id: @quote_id)
        raise Quotes::Domain::Repositories::Command::QuoteHistoryCommandRepository::AlreadyExistsError
      end
    end

    use_case = described_class.new(
      quote_history_query_repository: query,
      quote_history_command_repository: conflict_once_command.new(inner:, history_key_date:, quote_id: q2.id)
    )

    result = use_case.call

    expect(result.quote.id).to eq(q2.id)
    expect(QuoteHistory.count).to eq(1)
    expect(QuoteHistory.first.quote_id).to eq(q2.id)
  end
end
