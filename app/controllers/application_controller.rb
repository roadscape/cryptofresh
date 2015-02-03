class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_asset
  before_filter :check_ref

  def check_asset
    asset = params[:asset]
    session[:asset] = asset if asset && Asset.valid?(asset)
    session[:asset] ||= 'USD'
  end

  def check_ref
    if params[:r] 
      if cookies[:referer].blank?
        cookies[:referer] ||= {:value => params[:r], :expires => 2.weeks.from_now}
      end
    end
  end

end
