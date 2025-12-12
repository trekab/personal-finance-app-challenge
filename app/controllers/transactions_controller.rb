class TransactionsController < ApplicationController

  # GET /transactions or /transactions.json
  def index
    @transactions = current_user.transactions

    # Apply search filter using scope
    @transactions = @transactions.search(params[:search]) if params[:search].present?


    # Apply category filter
    if params[:category].present? && params[:category] != 'All'
      @transactions = @transactions.where(category: params[:category])
    end

    # Apply sorting
    @transactions = case params[:sort]
                    when 'oldest'
                      @transactions.order(date: :asc)
                    when 'highest'
                      @transactions.order(amount: :desc)
                    when 'lowest'
                      @transactions.order(amount: :asc)
                    else # 'latest' or default
                      @transactions.order(date: :desc)
                    end

    # Pagination
    @pagy, @transactions = pagy(@transactions, items: 10)

    # Store current page for pagination display
    @current_page = @pagy.page
    @total_pages = @pagy.pages

    # Respond to Turbo requests
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
    @transaction.transaction_type = params[:transaction_type]
    @transaction.customizable_type = params[:customizable_type] if params[:customizable_type].present?
    @transaction.customizable_id = params[:customizable_id] if params[:customizable_id].present?
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user

    respond_to do |format|
      if @transaction.save
        format.html { redirect_back fallback_location: transactions_path, notice: "Transaction was successfully created." }
        format.json { render :index, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @transaction.errors, status: :unprocessable_content }
      end
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.expect(transaction: [ :date, :amount, :category, :transaction_type, :customizable_type, :customizable_id ])
    end
end
