class ApplicationController < ActionController::Base
  rescue_from Exception, with: :_render_500
  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :_render_404

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

  def _render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.message}" if e

    if request.format.to_sym == :json
      render json: { error: '404 error' }, status: 404
    else
      render 'errors/error_404', status: 404
    end
  end

  def _render_500(e = nil)
    logger.error "Rendering 500 with exception: #{e.message}" if e

    if request.format.to_sym == :json
      render json: { error: '500 error' }, status: 500
    else
      render 'errors/error_500', status: 500
    end
  end
end
