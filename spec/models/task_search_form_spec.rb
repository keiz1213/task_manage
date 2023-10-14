require 'rails_helper'

RSpec.describe TaskSearchForm do
  describe 'ソート' do
    it 'デフォルトで作成日の降順にソート' do
      task1 = create(:task)
      task2 = create(:task, :yesterday_task)
      task3 = create(:task, :day_before_yesterday_task)
      search_form = build(:task_search_form)
  
      expect(search_form.sort[0]).to eq task1
      expect(search_form.sort[1]).to eq task2
      expect(search_form.sort[2]).to eq task3
    end
  
    it '締め切りに近い順にソートできる' do
      task1 = create(:task, :due_tomorrow_task)
      task2 = create(:task, :due_two_days_after_tomorrow_task)
      task3 = create(:task, :due_day_after_tomorrow_task)
      search_form = build(:task_search_form, :sort_by_deadline)
  
      expect(search_form.sort[0]).to eq task1
      expect(search_form.sort[1]).to eq task3
      expect(search_form.sort[2]).to eq task2
    end
  end

  describe 'サーチ' do
    let!(:task1) { create(:task, title: 'りんご', description: 'バナナ', deadline: Time.current.since(5.days))}
    let!(:task2) { create(:task, title: 'スイカ', description: '桃', deadline: Time.current.since(3.days))}
    let!(:task3) { create(:task, title: 'メロン', description: 'いちご', deadline: Time.current.since(2.days))}
    let!(:task4) { create(:task, title: 'りんご', description: 'いちご', deadline: Time.current.since(4.days))}
    let!(:task5) { create(:task, title: 'パイナップル', description: 'いちご', deadline: Time.current.since(1.day))}

    it 'タイトルからキーワード検索できる' do
      task_search_form = build(:task_search_form, keyword: 'りんご')

      expect(task_search_form.search).to include task1, task4
    end

    it '説明からキーワード検索できる' do
      task_search_form = build(:task_search_form, keyword: 'いちご')

      expect(task_search_form.search).to include task3, task4, task5
    end

    it '検索結果を締切が近い順にソートできる' do
      task_search_form = build(:task_search_form, keyword: 'いちご', sort_by: 'deadline')
      result = task_search_form.search

      expect(result[0]).to eq task5
      expect(result[1]).to eq task3
      expect(result[2]).to eq task4
    end
  end
end
