# frozen_string_literal: true
#
require 'rails_helper'

RSpec.describe Checkout, type: :model do
  subject(:checkout) { create :checkout }

  describe '.total_amount_payable' do
    subject { checkout.total_amount_payable }

    let(:checkout) { build :checkout, total_amount: total_amount, total_amount_paid: total_amount_paid }

    context 'when we have paid more than we owe' do
      let(:total_amount_paid) { 10 }
      let(:total_amount) { 5 }

      it 'returns 0, since we owe no more money' do
        expect(subject).to eq(0)
      end
    end

    context 'when we have paid less than we owe' do
      let(:total_amount_paid) { 5 }
      let(:total_amount) { 10 }

      it 'returns the difference b/w what we paid and owe' do
        expect(subject).to eq(5)
      end
    end
  end
end
