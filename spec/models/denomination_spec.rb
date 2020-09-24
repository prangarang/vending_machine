# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join "spec/concerns/quantity_manageable_shared_examples_spec.rb"

RSpec.describe Denomination, type: :model do
  subject(:denomination) { create :denomination }

  it_behaves_like 'quantity_manageable'

  describe 'valdations' do
    it { should validate_uniqueness_of(:value) }
    it { should validate_presence_of(:value) }
    it { should validate_presence_of(:value) }

    describe 'value inclusion' do
      it 'does not allow unsupported denominations' do
        denomination.value = 4
        expect(denomination.valid?).to be(false)
        expect(denomination.errors.details[:value]).to eq([error: :inclusion, value: 4])
      end
    end
  end

  describe '.available' do
    subject { Denomination.available }

    before do
      @denom_1 = create(:denomination, value: 1, quantity: 1)
      create(:denomination, value: 2, quantity: 0)
      @denom_5 = create(:denomination, value: 5, quantity: 10)
      create(:denomination, value: 20, quantity: 0)
    end

    it 'returns only denominations with available quantity' do
      expect(subject).to match([@denom_1, @denom_5])
    end
  end
end
