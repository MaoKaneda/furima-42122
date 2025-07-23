class ApplicationController < ActionController::Base
  before_action :basic_auth

  private

  def basic_auth
    Rails.logger.info '=== Basic Auth Debug ==='
    Rails.logger.info "ENV['BASIC_AUTH_USER']: #{ENV['BASIC_AUTH_USER']}"
    Rails.logger.info "ENV['BASIC_AUTH_PASSWORD']: #{ENV['BASIC_AUTH_PASSWORD']}"
    Rails.logger.info "Request headers: #{request.headers['HTTP_AUTHORIZATION']}"

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
