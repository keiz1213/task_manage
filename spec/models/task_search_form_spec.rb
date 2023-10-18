require 'rails_helper'

RSpec.describe TaskSearchForm do
  describe 'ユーザーのタスクをソートする' do
    it 'デフォルトで作成日の新しい順にソート' do
      user = create(:user, :with_tasks_for_3_days)
      search_form = build(:task_search_form)
      tasks_order_by_created_at = user.tasks.recent

      expect(tasks_order_by_created_at.count).to be 3
      expect(search_form.sort_task(user)[0]).to eq tasks_order_by_created_at[0]
      expect(search_form.sort_task(user)[1]).to eq tasks_order_by_created_at[1]
      expect(search_form.sort_task(user)[2]).to eq tasks_order_by_created_at[2]
    end

    it '締め切りに近い順にソートできる' do
      user = create(:user, :with_tasks_separate_due_dates)
      search_form = build(:task_search_form, sort_by: 'deadline')
      tasks_order_by_deadline = user.tasks.deadline

      expect(tasks_order_by_deadline.count).to be 3
      expect(search_form.sort_task(user)[0]).to eq tasks_order_by_deadline[0]
      expect(search_form.sort_task(user)[1]).to eq tasks_order_by_deadline[1]
      expect(search_form.sort_task(user)[2]).to eq tasks_order_by_deadline[2]
    end

    it '優先度が高い順にソートできる' do
      user = create(:user, :with_tasks_separate_priority)
      search_form = build(:task_search_form, sort_by: 'high')
      tasks_order_by_high_priority = user.tasks.high_priority_first

      expect(tasks_order_by_high_priority.count).to be 3
      expect(search_form.sort_task(user)[0]).to eq tasks_order_by_high_priority[0]
      expect(search_form.sort_task(user)[1]).to eq tasks_order_by_high_priority[1]
      expect(search_form.sort_task(user)[2]).to eq tasks_order_by_high_priority[2]
    end

    it '優先度が低い順にソートできる' do
      user = create(:user, :with_tasks_separate_priority)
      search_form = build(:task_search_form, sort_by: 'low')
      tasks_order_by_low_priority = user.tasks.low_priority_first

      expect(tasks_order_by_low_priority.count).to be 3
      expect(search_form.sort_task(user)[0]).to eq tasks_order_by_low_priority[0]
      expect(search_form.sort_task(user)[1]).to eq tasks_order_by_low_priority[1]
      expect(search_form.sort_task(user)[2]).to eq tasks_order_by_low_priority[2]
    end
  end

  describe 'ユーザーのタスクを検索する' do
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

    describe '検索結果のソート' do
      let(:user) { create(:user) }

      it 'キーワード検索の結果を締切が近い順にソートできる' do
        task1 = create(:task, :due_tomorrow_task, title: '青りんご', user: user)
        task2 = create(:task, :due_two_days_after_tomorrow_task, title: '毒りんご', user: user)
        task3 = create(:task, :due_day_after_tomorrow_task, title: 'りんごちゃん', user: user)
        task4 = create(:task, title: 'バナナ', user: user)
        search_form = build(:task_search_form, keyword: 'りんご', sort_by: 'deadline')
        result = search_form.search(user)
  
        expect(user.tasks.count).to be 4
        expect(result.count).to be 3
        result.each do |task|
          expect(task.title).to match(/りんご/)
        end
        expect(result[0]).to eq task1
        expect(result[1]).to eq task3
        expect(result[2]).to eq task2
      end
  
      it 'キーワード検索の結果を優先順位が高い順にソートできる' do
        task1 = create(:task, title: '青りんご', user: user, priority: 'mid')
        task2 = create(:task, title: '毒りんご', user: user, priority: 'high')
        task3 = create(:task, title: 'りんごちゃん', user: user, priority: 'low')
        task4 = create(:task, title: 'バナナ', user: user)
  
        search_form = build(:task_search_form, keyword: 'りんご', sort_by: 'high')
        result = search_form.search(user)
  
        expect(user.tasks.count).to be 4
        expect(result.count).to be 3
        expect(result[0]).to eq task2
        expect(result[1]).to eq task1
        expect(result[2]).to eq task3
      end
  
      it 'キーワード検索の結果を優先順位が低い順にソートできる' do
        task1 = create(:task, title: '青りんご', user: user, priority: 'mid')
        task2 = create(:task, title: '毒りんご', user: user, priority: 'high')
        task3 = create(:task, title: 'りんごちゃん', user: user, priority: 'low')
        task4 = create(:task, title: 'バナナ', user: user)
  
        search_form = build(:task_search_form, keyword: 'りんご', sort_by: 'low')
        result = search_form.search(user)
  
        expect(user.tasks.count).to be 4
        expect(result.count).to be 3
        expect(result[0]).to eq task3
        expect(result[1]).to eq task1
        expect(result[2]).to eq task2
      end
  
      it 'ステータス検索の結果を締切が近い順にソートできる' do
        task1 = create(:task, :due_tomorrow_task, user: user, state: 'in_progress')
        task2 = create(:task, :due_day_after_tomorrow_task, user: user, state: 'not_started')
        task3 = create(:task, :due_two_days_after_tomorrow_task, user: user, state: 'in_progress')
        search_form = build(:task_search_form, state: 'in_progress', sort_by: 'deadline')
        result = search_form.search(user)
  
        expect(user.tasks.count).to be 3
        expect(result.count).to be 2
        expect(result[0]).to eq task1
        expect(result[1]).to eq task3
      end
  
      it 'ステータス検索の結果を優先順位が高い順にソートできる' do
        task1 = create(:task, user: user, state: 'in_progress', priority: 'low')
        task2 = create(:task, user: user, state: 'done', priority: 'high')
        task3 = create(:task, user: user, state: 'in_progress', priority: 'mid')
  
        search_form = build(:task_search_form, state: 'in_progress', sort_by: 'high')
        result = search_form.search(user)
  
        expect(user.tasks.count).to be 3
        expect(result.count).to be 2
        expect(result[0]).to eq task3
        expect(result[1]).to eq task1
      end
  
      it 'ステータス検索の結果を優先順位が低い順にソートできる' do
        task1 = create(:task, user: user, state: 'in_progress', priority: 'low')
        task2 = create(:task, user: user, state: 'done', priority: 'high')
        task3 = create(:task, user: user, state: 'in_progress', priority: 'mid')
  
        search_form = build(:task_search_form, state: 'in_progress', sort_by: 'low')
        result = search_form.search(user)
  
        expect(user.tasks.count).to be 3
        expect(result.count).to be 2
        expect(result[0]).to eq task1
        expect(result[1]).to eq task3
      end
    end
  end
end
