class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :pots, dependent: :destroy
  has_many :recurring_bills, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :name, presence: true

  validates :password, length: { minimum: 8 }, if: :password_digest_changed?

  def current_balance
    transactions.income.sum(:amount) - transactions.expense.sum(:amount)
  end

  def total_income
    transactions.income.sum(:amount)
  end

  def total_expense
    transactions.expense.sum(:amount)
  end

  def total_saved
    transactions.deposit.sum(:amount) - transactions.withdraw.sum(:amount)
  end

  has_many :recurring_bills, dependent: :destroy
  def overdue_bills
    recurring_bills.overdue.sum(:amount)
  end

  def upcoming_bills
    recurring_bills.upcoming.sum(:amount)
  end

  def paid_bills
    recurring_bills.where.not(id: recurring_bills.overdue.select(:id))
                   .where.not(id: recurring_bills.upcoming.select(:id))
                   .sum(:amount)
  end
end
