class Quote < ApplicationRecord
  has_many :quote_histories, dependent: :restrict_with_exception

  validates :text, presence: true
end
