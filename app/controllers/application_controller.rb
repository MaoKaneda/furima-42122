class ApplicationController < ActionController::Base
  # before_action :basic_auth

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  private

  def basic_auth
    authenticate_or_request_with_http_basic('FURIMA') do |username, password|
      username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end

  def render_404
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end
end
