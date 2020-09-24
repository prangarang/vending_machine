class DenominationsController < ApplicationController
  before_action :set_denomination, only: [:show, :update, :destroy]

  # GET /denominations
  def index
    @denominations = Denomination.all

    render json: @denominations
  end

  # GET /denominations/1
  def show
    render json: @denomination
  end

  # POST /denominations
  def create
    @denomination = Denomination.new(denomination_params)

    if @denomination.save
      render json: @denomination, status: :created, location: @denomination
    else
      render json: @denomination.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /denominations/1
  def update
    if @denomination.update(denomination_params)
      render json: @denomination
    else
      render json: @denomination.errors, status: :unprocessable_entity
    end
  end

  # DELETE /denominations/1
  def destroy
    @denomination.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_denomination
      @denomination = Denomination.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def denomination_params
      params.require(:denomination).permit(:value)
    end
end
