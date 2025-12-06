# frozen_string_literal: true

require_relative "kd_imagor/version"
require_relative "kd_imagor/configuration"
require_relative "kd_imagor/client"
require_relative "kd_imagor/url_builder"
require_relative "kd_imagor/filters"

require_relative "kd_imagor/railtie" if defined?(Rails::Railtie)

module KdImagor
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class SignatureError < Error; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration.validate!
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def client
      @client ||= Client.new(configuration)
    end

    def url(source, **options)
      client.url(source, **options)
    end

    def srcset(source, widths: [320, 640, 768, 1024, 1280], **options)
      client.srcset(source, widths: widths, **options)
    end
  end
end
