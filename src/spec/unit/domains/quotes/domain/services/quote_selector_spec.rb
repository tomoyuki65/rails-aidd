require "rails_helper"

RSpec.describe Quotes::Domain::Services::QuoteSelector do
  describe ".select!" do
    it "selects by yday modulo count" do
      quotes = [ :a, :b, :c ]
      date = Date.new(2026, 1, 1) # yday=1 -> index=1%3=1

      expect(described_class.select!(date:, quotes:)).to eq(:b)
    end

    it "is deterministic for the same date" do
      quotes = [ :a, :b, :c ]
      date = Date.new(2026, 4, 23)

      first = described_class.select!(date:, quotes:)
      second = described_class.select!(date:, quotes:)

      expect(first).to eq(second)
    end

    it "raises when quotes are empty" do
      expect do
        described_class.select!(date: Date.new(2026, 1, 1), quotes: [])
      end.to raise_error(described_class::EmptyQuotesError)
    end
  end
end
