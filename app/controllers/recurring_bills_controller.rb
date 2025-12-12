# app/controllers/recurring_bills_controller.rb
class RecurringBillsController < ApplicationController

  def index
    @recurring_bills = current_user.recurring_bills

    # Apply search filter
    if params[:search].present?
      @recurring_bills = @recurring_bills.where(
        "bill_title ILIKE ?", "%#{params[:search]}%"
      )
    end

    # Apply sorting
    @recurring_bills = case params[:sort]
                       when 'oldest'
                         @recurring_bills.order(created_at: :asc)
                       when 'asc'
                         @recurring_bills.order(bill_title: :asc)
                       when 'desc'
                         @recurring_bills.order(bill_title: :desc)
                       when 'highest'
                         @recurring_bills.order(amount: :desc)
                       when 'lowest'
                         @recurring_bills.order(amount: :asc)
                       when 'due_date'
                         @recurring_bills.by_due_date
                       else # 'latest' or nil
                         @recurring_bills.by_latest
                       end

    # Use instance methods instead of class methods with user_id
    @total_bills = current_user.recurring_bills.sum(:amount)
    @total_upcoming = current_user.upcoming_bills
    @total_overdue = current_user.overdue_bills
  end

  def new
    @recurring_bill = RecurringBill.new
  end

  def create
    @recurring_bill = RecurringBill.new(recurring_bill_params)
    @recurring_bill.user = current_user

    if @recurring_bill.save
      redirect_to recurring_bills_path, notice: 'Recurring bill was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  private
  def recurring_bill_params
    params.require(:recurring_bill).permit(
      :bill_title, :amount, :frequency_type, :day_of_month, :day_of_week, :is_overdue, :color
    )
  end
end