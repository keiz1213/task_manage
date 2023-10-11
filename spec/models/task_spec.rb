require 'rails_helper'

RSpec.describe Task, type: :model do
  it '有効なタスクであること' do
    expect(FactoryBot.build(:task)).to be_valid
  end

  describe 'バリデーション' do
    describe 'タスクのタイトル' do
      it '空ではないこと' do
        task = FactoryBot.build(:task, title: '')
        task.valid?
        expect(task.errors[:title]).to include("can't be blank")
      end

      it '30文字以内であること' do
        task = FactoryBot.build(:task, title: 'a' * 31)
        task.valid?
        expect(task.errors[:title]).to include("is too long (maximum is 30 characters)")
      end
    end

    describe 'タスクの優先順位' do
      it '空ではないこと' do
        task = FactoryBot.build(:task, priority: '')
        task.valid?
        expect(task.errors[:priority]).to include("can't be blank")
      end
    end

    describe 'タスクの期限' do
      it '空ではないこと' do
        task = FactoryBot.build(:task, deadline: '')
        task.valid?
        expect(task.errors[:deadline]).to include("can't be blank")
      end

      it '期限は現在よりも後であること' do
        task = FactoryBot.build(:task, deadline: Time.current.yesterday)
        task.valid?
        expect(task.errors[:deadline]).to include("は現在以降の日時である必要があります")
      end
    end

    describe 'タスクの状態' do
      it '空ではないこと' do
        task = FactoryBot.build(:task, state: '')
        task.valid?
        expect(task.errors[:state]).to include("can't be blank")
      end
    end
  end
end
