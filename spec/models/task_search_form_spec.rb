require 'rails_helper'

RSpec.describe TaskSearchForm do
  describe 'ソート' do
    it 'デフォルトで作成日の降順にソート' do
      task1 = create(:task)
      task2 = create(:task, :yesterday_task)
      task3 = create(:task, :day_before_yesterday_task)
      search_form = build(:task_search_form)

      expect(search_form.sort_task[0]).to eq task1
      expect(search_form.sort_task[1]).to eq task2
      expect(search_form.sort_task[2]).to eq task3
    end

    it '締め切りに近い順にソートできる' do
      task1 = create(:task, :due_tomorrow_task)
      task2 = create(:task, :due_two_days_after_tomorrow_task)
      task3 = create(:task, :due_day_after_tomorrow_task)
      search_form = build(:task_search_form, :sort_by_deadline)

      expect(search_form.sort_task[0]).to eq task1
      expect(search_form.sort_task[1]).to eq task3
      expect(search_form.sort_task[2]).to eq task2
    end
  end

  describe 'サーチ' do
    it 'タイトルからキーワード検索できる' do
      create(:task, title: '青りんご', description: 'バナナ')
      create(:task, title: 'スイカ', description: '桃太郎')
      create(:task, title: 'メロン', description: 'いちごみるく')
      create(:task, title: 'りんごちゃん', description: 'いちご摘み')
      create(:task, title: 'パイナップル', description: 'いちご')

      task_search_form = build(:task_search_form, keyword: 'りんご')
      result = task_search_form.search

      expect(result.count).to be 2
      result.each do |task|
        expect(task.title).to match(/りんご/)
      end
    end

    it '説明からキーワード検索できる' do
      create(:task, title: '青りんご', description: 'バナナ')
      create(:task, title: 'スイカ', description: '桃太郎')
      create(:task, title: 'メロン', description: 'いちごみるく')
      create(:task, title: 'りんごちゃん', description: 'いちご摘み')
      create(:task, title: 'パイナップル', description: 'いちご')

      task_search_form = build(:task_search_form, keyword: 'いちご')
      result = task_search_form.search

      expect(result.count).to be 3
      result.each do |task|
        expect(task.description).to match(/いちご/)
      end
    end

    it 'ステータスで検索できる' do
      create(:task, title: '青りんご', state: 'not_started')
      create(:task, title: 'スイカ', state: 'not_started')
      create(:task, title: 'メロン', state: 'in_progress')
      create(:task, title: 'りんごちゃん', state: 'in_progress')
      create(:task, title: 'パイナップル', state: 'done')

      task_search_form = build(:task_search_form, state: 'in_progress')
      result = task_search_form.search
      expect(result.count).to be 2
      result.each do |task|
        expect(task.state).to eq 'in_progress'
      end
    end

    it 'キーワード検索の結果を締切が近い順にソートできる' do
      create(:task, title: '青りんご', description: 'バナナ', deadline: Time.current.since(5.days))
      create(:task, title: 'スイカ', description: '桃太郎', deadline: Time.current.since(3.days))
      create(:task, title: 'メロン', description: 'いちごみるく', deadline: Time.current.since(2.days))
      create(:task, title: 'りんごちゃん', description: 'いちご摘み', deadline: Time.current.since(4.days))
      create(:task, title: 'パイナップル', description: 'いちご', deadline: Time.current.since(1.day))

      task_search_form = build(:task_search_form, keyword: 'いちご', sort_by: 'deadline')
      result = task_search_form.search
      expect(result.count).to be 3
      expect(result[0].title).to eq 'パイナップル'
      expect(result[1].title).to eq 'メロン'
      expect(result[2].title).to eq 'りんごちゃん'
    end

    it 'ステータス検索の結果を締切が近い順にソートできる' do
      create(:task, title: '青りんご', state: 'not_started', deadline: Time.current.since(5.days))
      create(:task, title: 'スイカ', state: 'not_started', deadline: Time.current.since(3.days))
      create(:task, title: 'メロン', state: 'not_started', deadline: Time.current.since(2.days))
      create(:task, title: 'りんごちゃん', state: 'in_progress', deadline: Time.current.since(4.days))
      create(:task, title: 'パイナップル', state: 'done', deadline: Time.current.since(1.day))

      task_search_form = build(:task_search_form, state: 'not_started', sort_by: 'deadline')
      result = task_search_form.search
      expect(result.count).to be 3
      expect(result[0].title).to eq 'メロン'
      expect(result[1].title).to eq 'スイカ'
      expect(result[2].title).to eq '青りんご'
    end
  end
end
