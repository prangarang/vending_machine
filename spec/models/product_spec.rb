require 'rails_helper'
require Rails.root.join "spec/concerns/quantity_manageable_shared_examples_spec.rb"

RSpec.describe Product, type: :model do
  subject(:product) { build(:product) }

  describe 'associations' do
    it { is_expected.to have_many(:checkouts) }
  end

  it_behaves_like 'quantity_manageable'
end
