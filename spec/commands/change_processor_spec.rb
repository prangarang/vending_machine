# frozen_string_literal: true

require 'rails_helper'

describe ChangeProcessor do
  describe '#process!' do
    subject { described_class.new(parameters).process! }

    let(:parameters) { { total_amount: total_amount, denominations: denominations, calculator: calculator } }
    let(:total_amount) { 100 }
    let(:denomination_1) { FactoryBot.create(:denomination, value: 1, quantity: 1) }
    let(:denomination_2) { FactoryBot.create(:denomination, value: 2, quantity: 2) }
    let(:denominations) { [denomination_1, denomination_2] }
    let(:change_result) do
      Change.new(2, { denomination_1 => 1, denomination_2 => 1 }, total_amount)
    end
    let(:calculator) { double(ChangeCalculator) }
    let(:calculator_instance) { instance_double(ChangeCalculator, calculate: change_result) }

    before do
      allow(calculator).to receive(:new).with(denominations, total_amount).and_return(calculator_instance)
    end

    context 'when no calculator is provided' do
      let(:parameters) { { total_amount: total_amount, denominations: denominations } }
      it 'uses the ChangeCalculator unless overridden' do
        expect_any_instance_of(ChangeCalculator).to receive(:calculate).and_return(change_result)
        subject
      end
    end

    context 'when change is returned by the calculator' do
      it 'decrements the quantity of the denominations' do
        subject
        # We started with 1 of 1 pence and 2 of 2 pence
        # Change object has used 1 of 1 pence and 1 of 2 pence.
        # Therefore we have no 1 pence left and 1 2 pence left
        expect(denomination_1.reload.quantity).to eq(0)
        expect(denomination_2.reload.quantity).to eq(1)
      end

      it 'returns the change' do
        expect(subject).to eq(change_result)
      end
    end

    context 'if the calculator is unable to calculate change' do
      before { expect(calculator_instance).to receive(:calculate).and_raise(ChangeCalculator::ChangeIncalculableError) }

      it 'raises a processing error' do
        expect { subject }.to raise_error { ChangeProcessor::ProcessingError }
      end
    end
  end
end
