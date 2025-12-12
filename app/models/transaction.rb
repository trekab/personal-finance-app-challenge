class Transaction < ApplicationRecord
  belongs_to :user

  enum :transaction_type, { deposit: 0,
                            withdraw: 1,
                            expense: 2,
                            income: 3 }, validate: true

  # Validations
  validates :category, presence: true
  validates :date, presence: true
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true

  # Search scope for enum and text fields
  scope :search, ->(term) {
    return all if term.blank?

    search_term = term.downcase

    # Find matching enum keys
    matching_types = transaction_types.keys.select { |type| type.include?(search_term) }

    if matching_types.any?
      where(
        "category ILIKE :search OR transaction_type IN (:types)",
        search: "%#{term}%",
        types: matching_types.map { |type| transaction_types[type] }
      )
    else
      where("category ILIKE :search", search: "%#{term}%")
    end
  }
end
