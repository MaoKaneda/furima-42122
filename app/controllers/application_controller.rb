class ApplicationController < ActionController::Base
  before_action :basic_auth

  private

  def basic_auth
    Rails.logger.info '=== Basic Auth Debug ==='
    Rails.logger.info "ENV['BASIC_AUTH_USER']: #{ENV['BASIC_AUTH_USER']}"
    Rails.logger.info "ENV['BASIC_AUTH_PASSWORD']: #{ENV['BASIC_AUTH_PASSWORD']}"
    Rails.logger.info "Request headers: #{request.headers['HTTP_AUTHORIZATION']}"
    Rails.logger.info "User-Agent: #{request.headers['HTTP_USER_AGENT']}"

    # 強制的にBasic認証を要求
    unless request.headers['HTTP_AUTHORIZATION']
      Rails.logger.info 'No authorization header found - requesting Basic Auth'
      response.headers['WWW-Authenticate'] = 'Basic realm="FURIMA"'
      render plain: 'Authentication required', status: :unauthorized
      return
    end

    authenticate_or_request_with_http_basic('FURIMA') do |username, password|
      Rails.logger.info "Auth attempt - username: #{username}, password: #{password}"
      result = username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
      Rails.logger.info "Auth result: #{result}"
      Rails.logger.info "Expected username: #{ENV['BASIC_AUTH_USER']}, got: #{username}"
      Rails.logger.info "Expected password: #{ENV['BASIC_AUTH_PASSWORD']}, got: #{password}"
      result
    end
  end
end
