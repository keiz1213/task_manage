class ApplicationController < ActionController::Base
  rescue_from Exception, with: :render500
  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :render404

  include SessionsHelper

  before_action :set_search_form
  before_action :logged_in_user

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  def set_search_form
    @search_form = TaskSearchForm.new(search_params)
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = 'ログインしてください'
      redirect_to login_url, status: :see_other
    end
  end

  private

  def search_params
    params[:search].present? ? params.require(:search).permit(:keyword, :sort_by, :state, :tag_name) : {}
  end

  def render404(error = nil)
    logger.info "Rendering 404 with exception: #{error.message}" if error

    if request.format.to_sym == :json
      render json: { error: '404 error' }, status: :not_found
    else
      render 'errors/error_404', layout: 'errors', status: :not_found
    end
  end

  def render500(error = nil)
    logger.error "Rendering 500 with exception: #{error.message}" if error

    if request.format.to_sym == :json
      render json: { error: '500 error' }, status: :internal_server_error
    else
      render 'errors/error_500', layout: 'errors', status: :internal_server_error
    end
  end
end
