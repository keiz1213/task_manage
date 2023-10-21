master_user = User.find_or_create_by!(email: 'master@example.com') do |user|
  user.name = 'master'
  user.password = 'password'
  user.password_confirmation = 'password'
  user.admin = true
end
