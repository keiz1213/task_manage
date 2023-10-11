FactoryBot.define do
  factory :task do
    title { 'test title' }
    description { 'test description' }
    priority { 'low' }
    deadline { Time.mktime(2100,1,2,3,4) }
    state { 'not_started' }
  end
end
