# frozen_string_literal: true

shared_examples_for 'quantity_manageable' do
  let(:model) { described_class }
  let(:instance) { build(model.to_s.underscore.to_sym, quantity: initial_quantity) }

  describe '#available?' do
    subject { instance.available? }

    context 'when quantity is less than 1' do
      let(:initial_quantity) { 0 }
      it { is_expected.to be(false) }
    end

    context 'when quantity is more than 0' do
      let(:initial_quantity) { 1 }
      it { is_expected.to be(true) }
    end
  end

  describe '#decrement_quantity!' do
    subject { instance.decrement_quantity! }

    context 'when the new quantity is less than 0' do
      let(:initial_quantity) { 0 }
      it 'raises an error' do
        expect { subject }.to raise_error(QuantityManageable::UnableToDecrementQuantityError)
      end
    end

    context 'when the new quantity is more than 0' do
      let(:initial_quantity) { 1 }

      context 'when no decrement value is passed in' do
        it 'decrements the quantity based by 1' do
          expect { subject }.to change { instance.quantity }.from(1).to(0)
        end
      end

      context 'when a decrement value is passed in' do
        subject { instance.decrement_quantity!(2) }

        let(:initial_quantity) { 3 }

        it 'decrements the quantity based by 1' do
          expect { subject }.to change { instance.quantity }.from(3).to(1)
        end
      end
    end
  end
end
