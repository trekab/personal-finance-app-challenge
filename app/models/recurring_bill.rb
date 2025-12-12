class RecurringBill < ApplicationRecord
  belongs_to :user
  FREQUENCIES = %w[Weekly Monthly Yearly].freeze

  validates :bill_title, :amount, :frequency_type, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :frequency_type, inclusion: { in: FREQUENCIES }

  validates :day_of_week, presence: true, if: -> { frequency_type == 'Weekly' }
  validates :day_of_month, presence: true, if: -> { frequency_type.in?(%w[Monthly Yearly]) }

  # Scopes
  scope :overdue, -> { where(next_due_date: Date.current..(Date.current + 7.days)) }
  scope :upcoming, -> { where(next_due_date: (Date.current + 8.days)..Date.current.end_of_month) }

  scope :by_latest, -> { order(created_at: :desc) }
  scope :by_due_date, -> { order(next_due_date: :asc) }

  # Totals
  def self.total_bills(user_id)
    where(user_id: user_id).sum(:amount)
  end

  def self.total_overdue(user_id)
    overdue.where(user_id: user_id).sum(:amount)
  end

  def self.total_upcoming(user_id)
    upcoming.where(user_id: user_id).sum(:amount)
  end

  # Instance methods
  def overdue?
    next_due_date.present? && next_due_date <= Date.current + 7.days
  end

  def upcoming?
    next_due_date.present? && next_due_date > Date.current + 7.days && next_due_date <= Date.current.end_of_month
  end

  # Callback for next_due_date calculation
  before_save :calculate_next_due_date, if: -> { next_due_date.nil? }

  # Format the frequency for display (e.g., "Monthly - 1st", "Weekly - Monday")
  def frequency_display
    case frequency_type
    when 'Monthly'
      "Monthly - #{day_with_suffix(day_of_month)}"
    when 'Weekly'
      "Weekly - #{day_of_week}"
    when 'Yearly'
      "Yearly - #{Date::MONTHNAMES[1]} #{day_with_suffix(day_of_month)}"
    end
  end

  private

  def calculate_next_due_date
    today = Date.current

    case frequency_type
    when 'Monthly'
      # Calculate next occurrence of this day in current or next month
      next_date = Date.new(today.year, today.month, [day_of_month, Date.civil(today.year, today.month, -1).day].min)
      next_date = next_date.next_month if next_date < today
      self.next_due_date = next_date
    when 'Weekly'
      # Calculate next occurrence of this day of week
      days_until = (Date::DAYNAMES.index(day_of_week) - today.wday) % 7
      days_until = 7 if days_until == 0 && next_due_date && next_due_date < today
      self.next_due_date = today + days_until
    when 'Yearly'
      # Calculate next occurrence of this day/month
      next_date = Date.new(today.year, 1, [day_of_month, Date.civil(today.year, today.month, -1).day].min)
      next_date = next_date.next_year if next_date < today
      self.next_due_date = next_date
    end
  end

  def day_with_suffix(day)
    case day
    when 1, 21, 31 then "#{day}st"
    when 2, 22 then "#{day}nd"
    when 3, 23 then "#{day}rd"
    else "#{day}th"
    end
  end
end