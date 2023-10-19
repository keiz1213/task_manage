class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :set_search_form

  def set_search_form
    @search_form = TaskSearchForm.new(search_params)
  end

  private

  def search_params
    params[:search].present? ? params.require(:search).permit(:keyword, :sort_by, :state) : {}
  end
end
