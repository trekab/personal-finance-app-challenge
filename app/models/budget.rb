class Budget < ApplicationRecord
  belongs_to :user

  validates :maximum_spend, presence: true, numericality: { greater_than: 0 }
  validates :theme, :category, presence: true

  THEMES = %w[Green Yellow Cyan Navy Red Purple]
  COLOR_MAP = {
    "Green"  => "#2f7f6b",
    "Yellow" => "#f6e58d",
    "Cyan"   => "#7ed6df",
    "Navy"   => "#8395a7",
    "Red"    => "#e55039",
    "Purple" => "#8e44ad"
  }

  validates :theme, uniqueness: { scope: :user_id, message: "is already used by another budget" }

  broadcasts_refreshes

  def self.available_themes(exclude_id = nil, user_id = nil)
    used_themes = if exclude_id
                       where(user_id: user_id).where.not(id: exclude_id).pluck(:theme)
                  else
                    where(user_id: user_id).pluck(:theme)
                  end
    THEMES - used_themes
  end

  def self.used_themes(exclude_id = nil, user_id = nil)
    if exclude_id
      where(user_id: user_id).where.not(id: exclude_id).pluck(:theme)
    else
      where(user_id: user_id).pluck(:theme)
    end
  end

  def theme_used?(theme, user_id)
    Budget.where(user_id: user_id)
          .where.not(id: id)
          .pluck(:theme)
          .include?(theme)
  end

  def spent_this_month
    Transaction.where(created_at: Time.now.beginning_of_month..Time.now,
                       category: self.category).sum(:amount)
  end

  def budget_transactions
    Transaction.where(category: self.category).order(created_at: :desc).limit(3)
  end

end
