# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckoutsController, type: :request do
  let(:response_body) { JSON.parse(response.body) }

  describe '#create' do
    subject { post checkouts_path, params }

    let(:params) do
      {
        params: {
          checkout: {
            product_id: product_id
          }
        }
      }
    end

    context 'when the product id is invalid' do
      let(:product_id) { 'doesntexist' }

      it 'does not persist any data' do
        expect { subject }.not_to change { Checkout.count }.from(0)
      end

      it 'returns unprocessable entity with errors' do
        subject

        expect(response.status).to eq(422)
        expect(response_body).to eq({ 'errors' => [{ 'title' => 'product_id is invalid' }] })
      end
    end

    context 'when the product id is valid' do
      let(:product) { create :product }
      let(:product_id) { product.id }

      it 'persists a new checkout record with the correct attributes' do
        expect { subject }.to change { Checkout.count }.from(0).to(1)

        checkout = Checkout.find(response_body['id'])
        expect(checkout.total_amount). to eq(product.price_pence)
        expect(checkout.total_amount_paid). to eq(0)
        expect(checkout.status). to eq('requires_payment')
      end

      it 'returns successful response with details about the checkout' do
        subject

        expect(response.status).to eq(201)
        expect(response_body).to eq(
          {
            'id' => Checkout.last.id,
            'total_amount' => product.price_pence,
            'total_amount_payable' => product.price_pence,
            'total_amount_paid' => 0,
            'status' => 'requires_payment',
            'change' => {}
          }
        )
      end
    end
  end

  describe '#update' do
    subject { patch checkout_path(checkout.id), params }

    let(:product) { create(:product, quantity: product_quantity) }
    let(:product_quantity) { 1 }
    let(:checkout) do
      create(:checkout, product: product, total_amount: total_amount, total_amount_paid: initial_total_amount_paid)
    end
    let(:total_amount) { 15 }
    let(:initial_total_amount_paid) { 0 }
    let(:denomination_5) { create(:denomination, value: 5, quantity: 10) }
    let(:denomination_2) { create(:denomination, value: 2, quantity: 10) }
    let(:denomination_1) { create(:denomination, value: 1, quantity: 10) }
    let(:params) do
      {
        params: {
          checkout: {
            denomination_id: denomination_5.id
          }
        }
      }
    end

    before do
      checkout
      product
      denomination_5
      denomination_2
      denomination_1
    end

    context 'when the denomination inserted does not meet the total_amount' do
      it 'increments the quantity inserted since we just received one' do
        expect { subject }.to change { denomination_5.reload.quantity }.from(10).to(11)
      end

      it 'updates the checkout record in the DB with the new total paid amount' do
        subject
        checkout.reload
        expect(checkout.total_amount_paid).to eq(5)
        expect(checkout.status).to eq('requires_payment')
      end

      it 'returns a successful response with updated checkout information' do
        subject

        expect(response.status).to eq(200)
        expect(response_body).to eq(
          {
            'id' => checkout.id,
            'status' => 'requires_payment',
            'total_amount' => 15,
            'total_amount_paid' => 5,
            'total_amount_payable' => 10,
            'change' => {}
          }
        )
      end
    end

    context 'when the denomination inserted crosses the total_amount' do
      shared_examples_for 'a fully paid checkout' do |options|
        it 'increments the quantity inserted' do
          expect { subject }.to change { denomination_5.reload.quantity }.from(10).to(11)
        end

        it 'decrements the product quantity available' do
          expect { subject }.to change { product.reload.quantity }.from(1).to(0)
        end

        it 'returns a successful response with updated checkout information' do
          subject

          expect(response.status).to eq(200)
          expect(response_body).to eq(
            {
              'id' => checkout.id,
              'status' => 'succeeded',
              'total_amount' => 15,
              'total_amount_paid' => options[:expected_total_paid],
              'total_amount_payable' => 0,
              'change' => options[:expected_change]
            }
          )
        end
      end

      context 'when the new total_paid equals the total_amount exactly' do
        # Set total amount paid to one denomination less than total amount so matches perfectly
        let(:initial_total_amount_paid) { total_amount - denomination_5.value }

        it_behaves_like 'a fully paid checkout',
                        {
                          expected_total_paid: 15,
                          expected_change: { 'denominations' => [], 'total_amount' => 0, 'coin_count' => 0 }
                        }
      end

      context 'when the new total_paid is more than the total_amount and change is required' do
        # Initial paid amount is 14. We are updating the checkout with a denomination of 5 for a total of 19.
        # The change should be 4 using 2 2 pence coins.
        let(:initial_total_amount_paid) { 14 }

        it_behaves_like 'a fully paid checkout',
                        {
                          expected_total_paid: 19,
                          expected_change: { 'denominations' => ['2' => 2], 'total_amount' => 4, 'coin_count' => 2 }
                        }
      end

      context 'when change cannot be produced for the new amount' do
        let(:total_amount) { 6 }
        # We will be inserting another 5, which results in a total paid of 10 and thus change of 4 (10 paid - 6 total amount)
        # We will have no 2s or 1s
        let(:initial_total_amount_paid) { 5 }

        before do
          # Decrement quantity available to only one for both 1 and 2 pence, which means cant meet the change requirement
          # of 4 (19-15)
          denomination_5.update!(quantity: 1)
          denomination_2.update!(quantity: 0)
          denomination_1.update!(quantity: 0)
        end

        it 'decrements the quantity of available denomination to refund the customer' do
          # Started with 1 5 pence b/c total paid was 5. We inserted another 5 to get to total of 10.
          # We should end with no more 5 pence because we returned the one inserted and the one inserted before to get
          # to initial paid amount of 5
          expect { subject }.to change { denomination_5.reload.quantity }.from(1).to(0)
        end

        it 'does not decrement the product quantity available since checkout was not successful' do
          expect { subject }.not_to change { product.reload.quantity }.from(1)
        end

        it 'returns an error response' do
          subject

          expect(response.status).to eq(503)
          expect(response_body).to eq(
            {
              'errors' => [
                {
                  'title' => 'Checkout failed due to insufficient change available. Returning 10 pence. '\
                                'Please try again later or with different denominations.'
                }
              ]
            }
          )
        end
      end
    end
  end
end
