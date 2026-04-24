class QuoteHistory < ApplicationRecord
  belongs_to :quote

  validates :date, presence: true
end
