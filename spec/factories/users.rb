FactoryBot.define do
  factory :user do
    name { 'test-user' }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { '12345678' }
    password_confirmation { '12345678' }

    trait :master_user do
      name { 'master' }
      email { 'master@example.com' }
    end
  end
end
