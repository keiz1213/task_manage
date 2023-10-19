module SystemHelpers
  def wait_for_css_appear(selector, wait_time = Capybara.default_max_wait_time)
    Timeout.timeout(wait_time) do
      loop until has_css?(selector)
    end
    yield if block_given?
  end

  def login_as(user, remember_me: true)
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    check 'ログインしたままにする' if remember_me
    click_button 'ログイン'
  end
end
