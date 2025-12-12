class Pot < ApplicationRecord
  belongs_to :user

  validates :target, presence: true, numericality: { greater_than: 0 }
  validates :theme, :pot_name, presence: true

  has_many :transactions, as: :customizable, dependent: :destroy

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

  # Calculate total saved in this pot
  def total_saved
    transactions.deposit.sum(:amount) - transactions.withdraw.sum(:amount)
  end

  # Calculate percentage towards target
  def percentage_saved
    return 0 if target.zero?
    ((total_saved / target) * 100).round(2)
  end

  # Check if target is reached
  def target_reached?
    total_saved >= target
  end

  # Remaining amount to reach target
  def remaining_amount
    [target - total_saved, 0].max
  end

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
    Pot.where(user_id: user_id)
          .where.not(id: id)
          .pluck(:theme)
          .include?(theme)
  end
end
