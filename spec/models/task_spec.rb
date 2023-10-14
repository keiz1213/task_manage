require 'rails_helper'

RSpec.describe Task do
  it '有効なタスクであること' do
    expect(build(:task)).to be_valid
  end

  describe 'バリデーション' do
    describe 'タスクのタイトル' do
      it '空ではないこと' do
        task = build(:task, title: '')
        task.valid?
        expect(task.errors[:title]).to include("を入力してください")
      end

      it '30文字以内であること' do
        task = build(:task, title: 'a' * 31)
        task.valid?
        expect(task.errors[:title]).to include("は30文字以内で入力してください")
      end
    end

    describe 'タスクの優先順位' do
      it '空ではないこと' do
        task = build(:task, priority: '')
        task.valid?
        expect(task.errors[:priority]).to include("を入力してください")
      end
    end

    describe 'タスクの期限' do
      it '空ではないこと' do
        task = build(:task, deadline: '')
        task.valid?
        expect(task.errors[:deadline]).to include("を入力してください")
      end

      it '期限は現在よりも後であること' do
        task = build(:task, deadline: Time.current.yesterday)
        task.valid?
        expect(task.errors[:deadline]).to include("は現在以降の日時である必要があります")
      end
    end

    describe 'タスクの状態' do
      it '空ではないこと' do
        task = build(:task, state: '')
        task.valid?
        expect(task.errors[:state]).to include("を入力してください")
      end
    end
  end
end
