FactoryBot.define do
  factory :task do
    title { 'test title' }
    description { 'test description' }
    priority { 'low' }
    sequence(:deadline) { |n| n.weeks.from_now }
    state { 'not_started' }
    user

    trait :yesterday_task do
      title { 'yesterday_task' }
      created_at { 1.day.ago }
    end

    trait :day_before_yesterday_task do
      title { 'day_before_yesterday_task' }
      created_at { 2.days.ago }
    end

    trait :due_tomorrow_task do
      title { 'due_after_1_day_task' }
      deadline { 1.day.from_now }
    end

    trait :due_day_after_tomorrow_task do
      title { 'due_after_2_day_task' }
      deadline { 2.days.from_now }
    end

    trait :due_two_days_after_tomorrow_task do
      title { 'due_after_3_day_task' }
      deadline { 3.days.from_now }
    end

    trait :low_priority_task do
      title { 'low_priority_task' }
      priority { 'low' }
    end

    trait :mid_priority_task do
      title { 'mid_priority_task' }
      priority { 'mid' }
    end

    trait :high_priority_task do
      title { 'high_priority_task' }
      priority { 'high' }
    end

    trait :not_started_task do
      title { 'not_started_task' }
      state { 'not_started' }
    end

    trait :in_progress_task do
      title { 'in_progress_task' }
      state { 'in_progress' }
    end

    trait :done_task do
      title { 'done_task' }
      state { 'done' }
    end

    trait :with_tags do
      after(:create) do |task|
        3.times { create(:tagging, task: task, tag: create(:tag)) }
      end
    end
  end
end
