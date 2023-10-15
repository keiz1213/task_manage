require 'factory_bot_rails'

# 重要度を指定してその重要度のタスクを9個つくる
def create_tasks(priority:)
  state = ''
  3.times do |i1|
    case i1
    when 0
      state = 'not_started'
    when 1
      state = 'in_progress'
    when 2
      state = 'done'
    end
    3.times do |i2|
      FactoryBot.create(
        :task,
        title: Faker::Book.unique.title,
        description: Faker::Lorem.sentence,
        priority: priority,
        deadline: Time.mktime(2100, (1 + i2), 2, 3, 4),
        state: state
      )
    end
  end
end

create_tasks(priority: 'low')
create_tasks(priority: 'mid')
create_tasks(priority: 'high')
