FactoryBot.define do
  factory :user do
    name { 'test-user' }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { '12345678' }
    password_confirmation { '12345678' }
    admin { true }

    trait :with_tagged_tasks do
      after(:create) { |user| create(:task, :with_tags, user: user) }
    end

    trait :with_tasks_for_3_days do
      after(:create) { |user| create(:task, user: user) }
      after(:create) { |user| create(:task, :yesterday_task, user: user) }
      after(:create) { |user| create(:task, :day_before_yesterday_task, user: user) }
    end

    trait :with_tasks_separate_due_dates do
      after(:create) { |user| create(:task, :due_tomorrow_task, user: user) }
      after(:create) { |user| create(:task, :due_day_after_tomorrow_task, user: user) }
      after(:create) { |user| create(:task, :due_two_days_after_tomorrow_task, user: user) }
    end

    trait :with_tasks_separate_priority do
      after(:create) { |user| create(:task, :low_priority_task, user: user) }
      after(:create) { |user| create(:task, :mid_priority_task, user: user) }
      after(:create) { |user| create(:task, :high_priority_task, user: user) }
    end

    trait :with_tasks_separate_state do
      after(:create) { |user| create(:task, :not_started_task, user: user) }
      after(:create) { |user| create(:task, :in_progress_task, user: user) }
      after(:create) { |user| create(:task, :done_task, user: user) }
    end

    trait :with_tasks_separate_title do
      after(:create) { |user| create(:task, title: '青りんご', description: 'バナナ', user: user) }
      after(:create) { |user| create(:task, title: 'スイカ', description: '桃太郎', user: user) }
      after(:create) { |user| create(:task, title: 'メロン', description: 'いちごみるく', user: user) }
      after(:create) { |user| create(:task, title: 'りんごちゃん', description: 'いちご摘み', user: user) }
      after(:create) { |user| create(:task, title: 'パイナップル', description: 'いちご', user: user) }
    end
  end
end
