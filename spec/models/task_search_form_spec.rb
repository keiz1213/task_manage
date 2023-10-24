require 'rails_helper'

RSpec.describe TaskSearchForm do
  describe '#sort_task' do
    it 'デフォルトで作成日の新しい順にソート' do
      user = create(:user, :with_tasks_for_3_days)
      search_form = build(:task_search_form)
      tasks_order_by_created_at = user.tasks.recent
      result = search_form.sort_task(user)

      expect(tasks_order_by_created_at.count).to be 3
      expect(result[0]).to eq tasks_order_by_created_at[0]
      expect(result[1]).to eq tasks_order_by_created_at[1]
      expect(result[2]).to eq tasks_order_by_created_at[2]
    end

    it '締め切りに近い順にソートできる' do
      user = create(:user, :with_tasks_separate_due_dates)
      search_form = build(:task_search_form, sort_by: 'deadline')
      tasks_order_by_deadline = user.tasks.deadline
      result = search_form.sort_task(user)

      expect(tasks_order_by_deadline.count).to be 3
      expect(result[0]).to eq tasks_order_by_deadline[0]
      expect(result[1]).to eq tasks_order_by_deadline[1]
      expect(result[2]).to eq tasks_order_by_deadline[2]
    end

    it '優先度が高い順にソートできる' do
      user = create(:user, :with_tasks_separate_priority)
      search_form = build(:task_search_form, sort_by: 'high')
      tasks_order_by_high_priority = user.tasks.high_priority_first
      result = search_form.sort_task(user)

      expect(tasks_order_by_high_priority.count).to be 3
      expect(result[0]).to eq tasks_order_by_high_priority[0]
      expect(result[1]).to eq tasks_order_by_high_priority[1]
      expect(result[2]).to eq tasks_order_by_high_priority[2]
    end

    it '優先度が低い順にソートできる' do
      user = create(:user, :with_tasks_separate_priority)
      search_form = build(:task_search_form, sort_by: 'low')
      tasks_order_by_low_priority = user.tasks.low_priority_first
      result = search_form.sort_task(user)

      expect(tasks_order_by_low_priority.count).to be 3
      expect(result[0]).to eq tasks_order_by_low_priority[0]
      expect(result[1]).to eq tasks_order_by_low_priority[1]
      expect(result[2]).to eq tasks_order_by_low_priority[2]
    end
  end

  describe '#narrow_down_by_state' do
    let(:user) { create(:user, :with_tasks_separate_state) }

    it '未着手のタスクを絞り込める' do
      search_form = build(:task_search_form, state: 'not_started')
      user_tasks = user.tasks
      result = search_form.narrow_down_by_state(user_tasks)

      expect(user_tasks.count).to be 3
      expect(result.count).to be 1
      expect(result[0].state).to eq 'not_started'
    end

    it '着手中のタスクを絞り込める' do
      search_form = build(:task_search_form, state: 'in_progress')
      user_tasks = user.tasks
      result = search_form.narrow_down_by_state(user_tasks)

      expect(user_tasks.count).to be 3
      expect(result.count).to be 1
      expect(result[0].state).to eq 'in_progress'
    end

    it '完了したタスクを絞り込める' do
      search_form = build(:task_search_form, state: 'done')
      user_tasks = user.tasks
      result = search_form.narrow_down_by_state(user_tasks)

      expect(user_tasks.count).to be 3
      expect(result.count).to be 1
      expect(result[0].state).to eq 'done'
    end
  end

  describe '#narrow_down_by_tag_name' do
    it 'タグで絞り込める' do
      user = create(:user)
      create_list(:task, 5, user: user)
      create(:tagging, task: user.tasks[0], tag: create(:tag, name: 'foo'))
      search_form = build(:task_search_form, tag_name: 'foo')
      user_tasks = user.tasks
      result = search_form.narrow_down_by_tag_name(user_tasks)

      expect(user_tasks.count).to be 5
      expect(result.count).to be 1
      expect(result[0].tags[0].name).to eq 'foo'
    end
  end

  describe '#search' do
    it 'タイトルからキーワード検索できる' do
      user = create(:user, :with_tasks_separate_title)
      search_form = build(:task_search_form, keyword: 'りんご')
      result = search_form.search(user)

      expect(user.tasks.count).to be 5
      expect(result.count).to be 2
      result.each do |task|
        expect(task.title).to match(/りんご/)
      end
    end

    it '説明からキーワード検索できる' do
      user = create(:user, :with_tasks_separate_title)
      search_form = build(:task_search_form, keyword: 'いちご')
      result = search_form.search(user)

      expect(user.tasks.count).to be 5
      expect(result.count).to be 3
      result.each do |task|
        expect(task.description).to match(/いちご/)
      end
    end

    it 'ステータスで検索できる' do
      user = create(:user, :with_tasks_separate_state)
      search_form = build(:task_search_form, state: 'in_progress')
      result = search_form.search(user)

      expect(user.tasks.count).to be 3
      expect(result.count).to be 1
      result.each do |task|
        expect(task.state).to eq 'in_progress'
      end
    end

    it 'タグで検索できる' do
      user = create(:user)
      create_list(:task, 5, user: user)
      create(:tagging, task: user.tasks[0], tag: create(:tag, name: 'foo'))
      search_form = build(:task_search_form, tag_name: 'foo')
      result = search_form.search(user)

      expect(user.tasks.count).to be 5
      expect(result.count).to be 1
      result.each do |task|
        expect(task.tags[0].name).to eq 'foo'
      end
    end
  end
end
