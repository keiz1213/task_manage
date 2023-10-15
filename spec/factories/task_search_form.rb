FactoryBot.define do
  factory :task_search_form do
    keyword { '' }
    sort_by { '' }
    state { '' }

    trait :sort_by_deadline do
      sort_by { 'deadline' }
    end

    trait :sort_by_priority_low do
      sort_by { 'low' }
    end

    trait :sort_by_priority_high do
      sort_by { 'high' }
    end
  end
end
