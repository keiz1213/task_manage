FactoryBot.define do
  factory :task do
    title { 'test title' }
    description { 'test description' }
    priority { 'low' }
    deadline { Time.mktime(2100, 1, 2, 3, 4) }
    state { 'not_started' }

    trait :yesterday_task do
      title { 'yesterday_task' }
      created_at { Time.current.ago(1.day) }
    end

    trait :day_before_yesterday_task do
      title { 'day_before_yesterday_task' }
      created_at { Time.current.ago(2.days) }
    end

    trait :due_tomorrow_task do
      title { 'due_after_1_day_task' }
      deadline { Time.current.since(1.day) }
    end

    trait :due_day_after_tomorrow_task do
      title { 'due_after_2_day_task' }
      deadline { Time.current.since(2.days) }
    end

    trait :due_two_days_after_tomorrow_task do
      title { 'due_after_3_day_task' }
      deadline { Time.current.since(3.days) }
    end
  end
end
