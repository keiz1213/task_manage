require 'rails_helper'

RSpec.describe Task, type: :model do
  it '有効なタスクであること' do
    expect(FactoryBot.build(:task)).to be_valid
  end
end
