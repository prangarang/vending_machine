# frozen_string_literal: true

class CheckoutsController < ApplicationController
  before_action :set_checkout, only: %i[show update destroy]

  # GET /checkouts/1
  def show
    render_checkout
  end

  # POST /checkouts
  def create
    product_id = checkout_creation_params[:product_id]
    begin
      product = Product.find(product_id)
    rescue ActiveRecord::RecordNotFound => e
      return render_error('product_id is invalid', :unprocessable_entity)
    end

    unless product.available?
      return render_error("product #{product_id} is not available. Please select an available product.", :unprocessable_entity)
    end

    @checkout = Checkout.new(product: product, total_amount: product.price_pence)

    if @checkout.save
      render json: @checkout, status: :created, location: @checkout
    else
      render json: @checkout.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /checkouts/1
  def update
    return render_error('Checkout has already succeeded. Please try a new checkout.', 422) if @checkout.succeeded?

    # Not sure if we want to do this.
    return render_error('Checkout failed. Please try a new checkout.', 422) if @checkout.failed?

    begin
      denomination = Denomination.find(checkout_update_params[:denomination_id])
    rescue ActiveRecord::RecordNotFound => e
      return render_error('denomination_id is invalid', :unprocessable_entity)
    end

    # Occurs outside of the transaction because we will handle the returning of money in rescue should something go wrong
    # and we will need to know that this money already exists in the system. If we rolled this back
    # then we would lose sight of it.
    denomination.increment_quantity!
    @checkout.increment_total_amount_paid!(denomination.value)

    if @checkout.succeeded?
      change = nil
      ActiveRecord::Base.transaction do
        change = ChangeProcessor.process_using_available_denoms!(@checkout.total_amount_balance.abs)
        @checkout.product.decrement_quantity!
      end
      render json: @checkout, change: change
    else
      render_checkout
    end
  rescue StandardError => e
    # If we hit any errors, then we should mark the checkout as failed and refund the total amount to the
    # customer. We should have this amount available to us, since they just gave it to us and there is only one
    # customer at a time so we havent given those coins to anyone else.
    @checkout.failed!
    change = ChangeProcessor.process_using_available_denoms!(@checkout.total_amount_paid)
    error_message = if e.is_a?(ChangeProcessor::ProcessingError)
                      "Checkout failed due to insufficient change available. Returning #{change.total_amount} pence. "\
               'Please try again later or with different denominations.'
                    else
                      "We are currently having issues checking you out. Returning #{change.total_amount} pence. "\
             'Please try again later.'
                    end

    render_error(error_message, :service_unavailable)
  end

  private

  def render_error(error_title, status)
    render json: { errors: [{ title: error_title }] }, status: status
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_checkout
    @checkout = Checkout.find(params[:id])
  end

  def checkout_creation_params
    params.require(:checkout).permit(:product_id)
  end

  def checkout_update_params
    params.require(:checkout).permit(:denomination_id)
  end

  def render_checkout
    render json: @checkout
  end
end
