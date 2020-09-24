# frozen_string_literal: true

require 'rails_helper'

describe ChangeCalculator do
  describe '#calculate' do
    subject { described_class.new(denominations_hash.values, total_amount).calculate }

    let(:denominations_hash) do
      hash = {}
      Denomination::SUPPORTED_DENOMINATIONS.each do |val|
        denom = FactoryBot.create(:denomination, value: val, quantity: quantity)
        hash[denom.value] = denom
      end
      hash
    end
    let(:quantity) { 5 }

    before { denominations_hash }

    context 'When able to compute change' do
      context 'using 1 coin' do
        let(:total_amount) { 50 }

        it 'returns a change object with the correct total coins and the coins used' do
          expect(subject.coin_count).to eq(1)
          expect(subject.coins_used).to eq({ denominations_hash[50] => 1 })
        end
      end

      context 'Using multiple coins' do
        let(:total_amount) { 44 }

        it 'returns a change object with the correct total coins and the coins used' do
          expect(subject.coin_count).to eq(4)
          expect(subject.coins_used).to eq({ denominations_hash[20] => 2, denominations_hash[2] => 2 })
        end
      end

      context 'Using coins that exhaust quantity' do
        # We need to use up all our 200, 100, and 5's to get to this
        let(:total_amount) { 1505 }

        it 'returns a change object with the correct total coins and the coins used' do
          expect(subject.coin_count).to eq(11)
          expect(subject.coins_used).to eq(
            { denominations_hash[100] => 5, denominations_hash[200] => 5, denominations_hash[5] => 1 }
          )
        end
      end
    end

    context 'when we cannot compute the change' do
      context 'because total is higher than available change' do
        # Just set the total amount to double the quantity of the highest denomination
        let(:total_amount) { Denomination::SUPPORTED_DENOMINATIONS.max * quantity * 2 }

        it 'returns a change object with the correct total coins and the coins used' do
          expect { subject }.to raise_error { ChangeCalculator::ChangeIncalculableError }
        end
      end

      context 'because we do not have the combination of coins to produce the total' do
        # If we only have 1-1 and 1-2, then can't produce 4
        let(:total_amount) { 4 }
        let(:quantity) { 1 }

        it 'returns a change object with the correct total coins and the coins used' do
          expect { subject }.to raise_error { ChangeCalculator::ChangeIncalculableError }
        end
      end
    end
  end
end
