master_user = User.find_or_create_by!(email: 'master@example.com') do |user|
  user.name = 'master'
  user.password = 'password'
  user.password_confirmation = 'password'
end

tasks_without_user = Task.where(user_id: nil)
if tasks_without_user.any?
  tasks_without_user.find_each do |task|
    task.update!(user_id: master_user.id)
  end
end
