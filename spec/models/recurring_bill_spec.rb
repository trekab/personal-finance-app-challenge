# spec/models/recurring_bill_spec.rb
require 'rails_helper'

RSpec.describe RecurringBill, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  after { travel_back }

  describe 'validations' do
    it { should belong_to(:user) }

    it { should validate_presence_of(:bill_title) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:frequency_type) }
    it { should validate_inclusion_of(:frequency_type).in_array(%w[Monthly Weekly Yearly]) }

    context 'conditional validations' do
      it 'requires day_of_month for Monthly' do
        bill = build(:recurring_bill, frequency_type: 'Monthly', day_of_month: nil)
        expect(bill).not_to be_valid
        expect(bill.errors[:day_of_month]).to include("can't be blank")
      end

      it 'requires day_of_week for Weekly' do
        bill = build(:recurring_bill, frequency_type: 'Weekly', day_of_week: nil)
        expect(bill).not_to be_valid
        expect(bill.errors[:day_of_week]).to include("can't be blank")
      end
    end
  end

  describe 'callbacks' do
    it 'calculates next_due_date before save' do
      travel_to Date.new(2025, 1, 10) do
        bill = create(:recurring_bill, user: user, frequency_type: "Weekly", day_of_week: "Monday")
        # Next Monday from Jan 10, 2025 is Jan 13, 2025
        expect(bill.next_due_date).to eq(Date.new(2025, 1, 13))
      end
    end
  end

  describe 'scopes' do
    before do
      # explicitly set created_at to ensure deterministic ordering
      @overdue_bill = create(:recurring_bill, user: user, amount: 50, frequency_type: "Weekly",
                             day_of_week: "Monday", next_due_date: Date.new(2025, 1, 12),
                             created_at: 1.day.ago)
      @upcoming_bill = create(:recurring_bill, user: user, amount: 100, frequency_type: "Weekly",
                              day_of_week: "Monday", next_due_date: Date.new(2025, 1, 20),
                              created_at: Time.current)
    end

    it '.overdue returns bills within next 7 days' do
      travel_to Date.new(2025, 1, 10) do
        expect(RecurringBill.overdue).to include(@overdue_bill)
        expect(RecurringBill.overdue).not_to include(@upcoming_bill)
      end
    end

    it '.upcoming returns bills after 7 days to month end' do
      travel_to Date.new(2025, 1, 10) do
        expect(RecurringBill.upcoming).to include(@upcoming_bill)
        expect(RecurringBill.upcoming).not_to include(@overdue_bill)
      end
    end

    it '.by_latest orders by created_at descending' do
      expect(RecurringBill.by_latest.first).to eq(@upcoming_bill)
    end

    it '.by_due_date orders by next_due_date ascending' do
      expect(RecurringBill.by_due_date.first).to eq(@overdue_bill)
    end
  end

  describe 'class methods: totals' do
    before do
      create(:recurring_bill, user: user, amount: 50, frequency_type: "Weekly", day_of_week: "Monday", next_due_date: Date.new(2025, 1, 12))
      create(:recurring_bill, user: user, amount: 100, frequency_type: "Weekly", day_of_week: "Monday", next_due_date: Date.new(2025, 1, 20))
    end

    it '.total_bills sums all bills' do
      expect(RecurringBill.total_bills(user.id)).to eq(150)
    end

    it '.total_overdue sums overdue only' do
      travel_to Date.new(2025, 1, 10) do
        expect(RecurringBill.total_overdue(user.id)).to eq(50)
      end
    end

    it '.total_upcoming sums upcoming only' do
      travel_to Date.new(2025, 1, 10) do
        expect(RecurringBill.total_upcoming(user.id)).to eq(100)
      end
    end
  end

  describe 'instance methods' do
    let(:overdue_bill) { create(:recurring_bill, user: user, amount: 50, frequency_type: "Weekly", day_of_week: "Monday", next_due_date: Date.new(2025, 1, 12)) }
    let(:upcoming_bill) { create(:recurring_bill, user: user, amount: 100, frequency_type: "Weekly", day_of_week: "Monday", next_due_date: Date.new(2025, 1, 20)) }

    it '#overdue? returns true if next_due_date within 7 days' do
      travel_to Date.new(2025, 1, 10) do
        expect(overdue_bill.overdue?).to be true
        expect(upcoming_bill.overdue?).to be false
      end
    end

    it '#upcoming? returns true if next_due_date after 7 days to month end' do
      travel_to Date.new(2025, 1, 10) do
        expect(overdue_bill.upcoming?).to be false
        expect(upcoming_bill.upcoming?).to be true
      end
    end

    it '#frequency_display formats correctly' do
      monthly_bill = build(:recurring_bill, frequency_type: 'Monthly', day_of_month: 1)
      weekly_bill = build(:recurring_bill, frequency_type: 'Weekly', day_of_week: 'Monday')
      yearly_bill = build(:recurring_bill, frequency_type: 'Yearly', day_of_month: 1)

      expect(monthly_bill.frequency_display).to eq("Monthly - 1st")
      expect(weekly_bill.frequency_display).to eq("Weekly - Monday")
      expect(yearly_bill.frequency_display).to eq("Yearly - January 1st")
    end
  end

end
