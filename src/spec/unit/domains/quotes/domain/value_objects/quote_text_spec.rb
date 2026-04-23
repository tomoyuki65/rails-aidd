require "rails_helper"

RSpec.describe Quotes::Domain::ValueObjects::QuoteText do
  describe ".new" do
    it "accepts allowed characters" do
      quote_text = described_class.new("吾輩は猫である。")
      expect(quote_text.value).to eq("吾輩は猫である。")
    end

    it "rejects ascii, spaces, and symbols" do
      expect { described_class.new("hello") }.to raise_error(ArgumentError)
      expect { described_class.new("こんにちは 世界") }.to raise_error(ArgumentError)
      expect { described_class.new("こんにちは!") }.to raise_error(ArgumentError)
    end
  end
end
