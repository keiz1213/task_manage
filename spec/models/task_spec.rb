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

  describe '#update_state' do
    context '現在のstateがnot_strtedの時' do
      it 'stateがin_progressに更新される' do
        task = create(:task)
        expect(task.state).to eq 'not_started'
        task.update_state
        expect(task.state).to eq 'in_progress'
      end
    end

    context '現在のstateがin_progressの時' do
      it 'stateがdoneに更新される' do
        task = create(:task, state: 'in_progress')
        expect(task.state).to eq 'in_progress'
        task.update_state
        expect(task.state).to eq 'done'
      end
    end

    context '現在のstateがdoneの時' do
      it 'stateがnot_startedに更新される' do
        task = create(:task, state: 'done')
        expect(task.state).to eq 'done'
        task.update_state
        expect(task.state).to eq 'not_started'
      end
    end
  end

  describe '#save_tag' do
    context 'タスクにタグが付いていない時' do
      it 'タスクにタグを登録できる' do
        task = create(:task)
        expect(task.tags.count).to be 0
        tag_list = Tag.build_tag_list('foo,bar,baz')
        task.save_tag(tag_list)
        expect(task.tags.count).to be 3
      end
    end

    context 'タスクにタグが付いる時' do
      it 'タグを追加できる' do
        task = create(:task, :with_tags)
        expect(task.tags.count).to be 3
        tag_list = Tag.build_tag_list('tag-0, tag-1, tag-2, foo')
        task.save_tag(tag_list)
        expect(task.tags.count).to be 4
      end

      it 'タグを減らすことができる' do
        task = create(:task, :with_tags)
        expect(task.tags.count).to be 3
        tag_list = Tag.build_tag_list('tag-0, tag-1')
        task.save_tag(tag_list)
        expect(task.tags.count).to be 2
      end
    end
  end
end
