FactoryBot.define do
  factory :task do
    title { 'test title' }
    description { 'test description' }
    priority { 'low' }
    deadline { Time.current.tomorrow }
    state { 'not_started' }

    trait :non_title do
    end

    trait :over_30_length do
    end

    trait :non_description do
    end

    trait :non_priority do
    end

    trait :invalid_priority do
    end

    trait :non_deadline do
    end

    trait :deadline_before_current do
    end
  end
end
