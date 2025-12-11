class PotsController < ApplicationController
  before_action :set_pot, only: %i[ edit update destroy initiate_delete ]

  # GET /pots or /pots.json
  def index
    @pots = Pot.all
  end

  # GET /pots/new
  def new
    @pot = Pot.new
  end

  # GET /pots/1/edit
  def edit
    if @pot.user != current_user
      redirect_to root_path, alert: "Not authorized"
    end
  end

  # POST /pots or /pots.json
  def create
    @pot = Pot.new(pot_params)
    @pot.user = current_user

    respond_to do |format|
      if @pot.save
        format.html { redirect_to pots_path, notice: "Pot was successfully created." }
        format.json { render :index, status: :created, location: @pot }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @pot.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /pots/1 or /pots/1.json
  def update
    respond_to do |format|
      if @pot.user != current_user
        format.html { redirect_to pots_path, status: :forbidden }
        format.json { render json: @pot.errors, status: :forbidden }
      elsif @pot.update(pot_params)
        format.html { redirect_to @pot, notice: "Pot was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @pot }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @pot.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /pots/1 or /pots/1.json
  def destroy
    @pot.destroy!

    respond_to do |format|
      format.html { redirect_to pots_path, notice: "Pot was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def initiate_delete

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pot
      @pot = Pot.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pot_params
      params.expect(pot: [ :pot_name, :target, :theme, :user_id ])
    end
end
