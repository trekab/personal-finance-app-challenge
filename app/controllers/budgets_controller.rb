class BudgetsController < ApplicationController
  before_action :set_budget, only: %i[ edit update destroy initiate_delete ]

  # GET /budgets or /budgets.json
  def index
    @budgets = current_user.budgets
  end

  # GET /budgets/new
  def new
    @budget = Budget.new
  end

  # GET /budgets/1/edit
  def edit
    if @budget.user != current_user
      redirect_to root_path, alert: "Not authorized"
    end
  end

  # POST /budgets or /budgets.json
  def create
    @budget = Budget.new(budget_params)
    @budget.user = current_user

    respond_to do |format|
      if @budget.save
        format.html { redirect_to budgets_path, notice: "Budget was successfully created." }
        format.json { render :index, status: :created, location: @budget }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @budget.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /budgets/1 or /budgets/1.json
  def update
    respond_to do |format|
      if @budget.user != current_user
        format.html { redirect_to budgets_path, status: :forbidden }
        format.json { render json: @budget.errors, status: :forbidden }
      elsif @budget.update(budget_params)
        format.html { redirect_to budgets_path, notice: "Budget was successfully updated.", status: :see_other }
        format.json { render :index, status: :ok, location: @budget }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @budget.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /budgets/1 or /budgets/1.json
  def destroy
    @budget.destroy!

    respond_to do |format|
      format.html { redirect_to budgets_path, notice: "Budget was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def initiate_delete

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_budget
      @budget = Budget.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def budget_params
      params.expect(budget: [ :category, :maximum_spend, :theme, :user_id ])
    end
end
