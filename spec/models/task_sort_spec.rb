require 'rails_helper'

RSpec.describe TaskSort do
  it 'デフォルトで作成日順にソート' do
    task1 = create(:task)
    task2 = create(:task, :yesterday_task)
    task3 = create(:task, :day_before_yesterday_task)
    sort_task = build(:task_sort)

    expect(sort_task.result[0]).to eq task1
    expect(sort_task.result[1]).to eq task2
    expect(sort_task.result[2]).to eq task3
  end

  it '締め切りに近い順にソートできる' do
    task1 = create(:task, :due_tomorrow_task)
    task2 = create(:task, :due_two_days_after_tomorrow_task)
    task3 = create(:task, :due_day_after_tomorrow_task)
    sort_task = build(:task_sort, :sort_by_deadline)

    expect(sort_task.result[0]).to eq task1
    expect(sort_task.result[1]).to eq task3
    expect(sort_task.result[2]).to eq task2
  end
end
