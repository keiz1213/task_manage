RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV['WITH_HEAD'].present?
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end
  end
end

Capybara.add_selector(:test) do
  css { |val| %Q([data-test=#{val}])}
end
