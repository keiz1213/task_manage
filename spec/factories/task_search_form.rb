FactoryBot.define do
  factory :task_search_form do
    keyword { '' }
    sort_by { '' }

    trait :sort_by_deadline do
      sort_by { 'deadline' }
    end
  end
end
