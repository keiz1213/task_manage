# 重要度を指定してその重要度のタスクを9個つくる
def create_tasks(user:, priority:)
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
      user.tasks.create(
        title: Faker::Book.unique.title,
        description: Faker::Lorem.sentence,
        priority: priority,
        deadline: Time.mktime(2100, (1 + i2), 2, 3, 4),
        state: state
      )
    end
  end
end

master_user = User.find_or_create_by!(email: 'master@example.com') do |user|
  user.name = 'master'
  user.password = 'password'
  user.password_confirmation = 'password'
  user.admin = true
end
create_tasks(user: master_user, priority: 'low')
create_tasks(user: master_user, priority: 'mid')
create_tasks(user: master_user, priority: 'high')
