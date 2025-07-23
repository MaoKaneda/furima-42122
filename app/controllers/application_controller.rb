class ApplicationController < ActionController::Base
  before_action :basic_auth

  private

  def basic_auth
    Rails.logger.info '=== Basic Auth Method Started ==='
    Rails.logger.info "Current controller: #{controller_name}"
    Rails.logger.info "Current action: #{action_name}"
    Rails.logger.info "Basic Auth Debug: BASIC_AUTH_USER=#{ENV['BASIC_AUTH_USER']}"
    Rails.logger.info "Basic Auth Debug: BASIC_AUTH_PASSWORD=#{ENV['BASIC_AUTH_PASSWORD']}"

    # 強制的にBasic認証を要求
    authenticate_or_request_with_http_basic('FURIMA') do |username, password|
      Rails.logger.info "Basic Auth Attempt: username=#{username}, password=#{password}"
      # 一時的に固定値でテスト
      result = username == 'admin' && password == 'password123'
      Rails.logger.info "Basic Auth Result: #{result}"
      result
    end
  end
end
