FactoryBot.define do
  factory :task_sort do
    sort_by { '' }

    trait :sort_by_deadline do
      sort_by { 'deadline' }
    end
  end
end
