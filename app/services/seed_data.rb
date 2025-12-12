class SeedData
  def call(email_address, password)
    ActiveRecord::Base.transaction do
      user = find_or_create_user(email_address, password)
      create_budgets_for_user(user)
      create_pots_for_user(user)
      create_transactions_for_user(user)
      create_recurring_bills(user)
    end
  end

  private

  def find_or_create_user(email_address, password)
    user = User.find_or_create_by!(email_address: email_address) do |u|
      u.name = "Test User"
      u.password = password
    end

    raise "Failed to create test user: #{user.errors.full_messages}" unless user.persisted?
    user
  end

  def create_budgets_for_user(user)
    existing_budgets = Budget.where(user: user).pluck(:category, :theme)
    existing_categories = existing_budgets.map(&:first).to_set
    existing_themes = existing_budgets.map(&:last).to_set

    available_themes = Budget::THEMES.reject { |theme| existing_themes.include?(theme) }

    budgets_to_create = Constants::Categories::LIST.filter_map do |category|
      next if existing_categories.include?(category)
      next if available_themes.empty? # No more unique themes available

      theme = available_themes.shift # Take and remove the first available theme

      {
        user_id: user.id,
        category: category,
        theme: theme,
        maximum_spend: rand(100_000),
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Budget.insert_all(budgets_to_create) if budgets_to_create.any?
  end

  def create_pots_for_user(user)
    pot_items = ["New Laptop", "New Car", "New iPhone", "Savings", "Holidays", "Secret Santa", "Build Fund"]
    existing_pots = Pot.where(user: user).pluck(:pot_name, :theme)
    existing_pot_names = existing_pots.map(&:first).to_set
    existing_themes = existing_pots.map(&:last).to_set

    available_themes = Pot::THEMES.reject { |theme| existing_themes.include?(theme) }

    pots_to_create = pot_items.filter_map do |item|
      next if existing_pot_names.include?(item)
      next if available_themes.empty? # No more unique themes available

      theme = available_themes.shift # Take and remove the first available theme

      {
        user_id: user.id,
        pot_name: item,
        theme: theme,
        target: rand(500_000),
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    inserted_pots = Pot.insert_all(pots_to_create, returning: [:id, :target]) if pots_to_create.any?

    # Create transactions for new pots only
    create_pot_transactions(user, inserted_pots) if inserted_pots
  end

  def create_pot_transactions(user, inserted_pots)
    transactions = []
    category = "General"

    inserted_pots.rows.each do |pot_id, target|
      running_balance = 0
      max_transactions = 5

      max_transactions.times do
        # Determine what transaction types are valid based on current balance
        available_types = ['deposit']
        available_types << 'withdraw' if running_balance > 0

        transaction_type = available_types.sample

        # Calculate valid amount range
        if transaction_type == 'deposit'
          # Can deposit up to remaining target amount
          remaining_target = target - running_balance
          max_amount = [remaining_target, target / 2].min # Don't fill pot too quickly
          next if max_amount <= 0
          amount = rand(1..max_amount)
        else # withdraw
          # Can only withdraw up to current balance
          max_amount = running_balance
          next if max_amount <= 0
          amount = rand(1..[max_amount, target / 4].min) # Withdraw smaller amounts
        end

        transactions << {
          date: Faker::Date.between(from: 1.month.ago, to: Date.today),
          user_id: user.id,
          amount: amount,
          category: category,
          customizable_id: pot_id,
          customizable_type: "Pot",
          transaction_type: transaction_type,
          created_at: Time.current,
          updated_at: Time.current
        }

        # Update running balance
        running_balance += amount if transaction_type == "deposit"
        running_balance -= amount if transaction_type == "withdraw"
      end
    end

    Transaction.insert_all(transactions) if transactions.any?
  end

  def create_transactions_for_user(user)
    # Check if transactions already exist to avoid duplicates
    return if Transaction.where(user: user, transaction_type: %w[income expense]).exists?

    transactions = Array.new(100) do
      transaction_type = %w[income expense].sample
      category = transaction_type == "income" ?
                   Constants::Categories::INCOMES.sample :
                   Constants::Categories::LIST.sample

      {
        date: Faker::Date.between(from: 5.months.ago, to: Date.today),
        user_id: user.id,
        amount: rand(1..500),
        category: category,
        transaction_type: transaction_type,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    # Insert in batches for better memory management
    transactions.each_slice(500) do |batch|
      Transaction.insert_all(batch)
    end
  end

  def create_recurring_bills(user)
    return if RecurringBill.where(user: user).exists?

    bills = []
    today = Date.current
    lists = ["Electricity", "Water", "Groceries", "Rent", "Utilities", "Car Insurance", "Car Repair", "Netflix"]

    lists.each do |list|
      day_of_month = rand(1..28)

      # Manually calculate next_due_date (same logic as the callback)
      next_date = Date.new(today.year, today.month, day_of_month)
      next_date = next_date.next_month if next_date < today

      bills << {
        user_id: user.id,
        bill_title: list,
        amount: rand(100..1000),
        frequency_type: "Monthly",
        day_of_month: day_of_month,
        next_due_date: next_date,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    RecurringBill.insert_all(bills)
  end

  def find_unique_theme(available_themes, existing_collection)
    available_themes.shuffle!
    available_themes.find { |theme| !theme_exists?(theme, existing_collection) } || available_themes.first
  end

  def theme_exists?(theme, collection)
    collection.is_a?(Set) ? collection.include?(theme) : collection.any? { |item| item.include?(theme) }
  end
end