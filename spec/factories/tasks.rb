FactoryBot.define do
  factory :task do
    title { 'test title' }
    description { 'test description' }
    priority { 'low' }
    deadline { Time.current.tomorrow }
    state { 'not_started' }
  end
end
