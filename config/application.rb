require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Furima42122
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    config.active_storage.variant_processor = :mini_magick
    
    # アセットプリコンパイルの設定
    config.assets.precompile += %w( 
      furima-logo-color.png 
      furima-logo-white.png 
      search.png 
      star.png 
      flag.png
      comment.png
      item-sample.png 
      icon_camera.png 
      google-play.png 
      app-store.svg 
      furima-intro01.png
      furima-intro02.png
      furima-intro03.png
      furima-intro04.png
      furima-intro05.png
      furima-intro06.png
      *.png 
      *.jpg 
      *.jpeg 
      *.gif 
      *.svg 
    )
    
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Deviseの設定
    config.i18n.default_locale = :en
    config.time_zone = 'Tokyo'
  end
end
