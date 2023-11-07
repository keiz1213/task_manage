class Guest::SessionsController < ApplicationController
  skip_before_action :logged_in_user
  skip_before_action :set_search_form

  def create
    guest = User.find_by(email: 'sample@example.com')
    login(guest)
    flash[:success] = 'ゲストとしてログインしました。自由にお使いください。'
    redirect_to tasks_path
  end
end
