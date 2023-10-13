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
  end
end
