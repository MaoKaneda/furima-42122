class ApplicationController < ActionController::Base
  before_action :basic_auth

  private

  def basic_auth
    Rails.logger.info "Basic Auth Debug: BASIC_AUTH_USER=#{ENV['BASIC_AUTH_USER']}"
    Rails.logger.info "Basic Auth Debug: BASIC_AUTH_PASSWORD=#{ENV['BASIC_AUTH_PASSWORD']}"

    authenticate_or_request_with_http_basic do |username, password|
      Rails.logger.info "Basic Auth Attempt: username=#{username}, password=#{password}"
      # 一時的に固定値でテスト
      result = username == 'admin' && password == 'password123'
      Rails.logger.info "Basic Auth Result: #{result}"
      result
    end
  end
end
