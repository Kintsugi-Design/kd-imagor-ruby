# frozen_string_literal: true

module KdImagor
  class Configuration
    attr_accessor :host, :secret, :signer_type, :signer_truncate
    attr_accessor :default_quality, :default_format, :default_fit
    attr_accessor :minio_endpoint, :minio_bucket, :minio_access_key, :minio_secret_key, :minio_region
    attr_accessor :presigned_url_expires_in
    attr_accessor :unsafe_mode, :auto_webp, :auto_avif

    def initialize
      @host = ENV.fetch("IMAGOR_URL", nil)
      @secret = ENV.fetch("IMAGOR_SECRET", nil)
      @signer_type = :sha1
      @signer_truncate = nil

      @default_quality = 80
      @default_format = nil
      @default_fit = "fit-in"

      @minio_endpoint = ENV.fetch("MINIO_ENDPOINT", nil)
      @minio_bucket = ENV.fetch("MINIO_BUCKET", nil)
      @minio_access_key = ENV.fetch("MINIO_ACCESS_KEY", nil)
      @minio_secret_key = ENV.fetch("MINIO_SECRET_KEY", nil)
      @minio_region = ENV.fetch("MINIO_REGION", "us-east-1")

      @presigned_url_expires_in = 1.hour if defined?(ActiveSupport::Duration)

      @unsafe_mode = false
      @auto_webp = true
      @auto_avif = false
    end

    def validate!
      if host.nil? || host.empty?
        raise ConfigurationError, "Imagor host is required. Set IMAGOR_URL environment variable or configure KdImagor.configure { |c| c.host = '...' }"
      end

      if !unsafe_mode && (secret.nil? || secret.empty?)
        raise ConfigurationError, "Imagor secret is required when unsafe_mode is disabled. Set IMAGOR_SECRET environment variable."
      end

      unless %i[sha1 sha256 sha512].include?(signer_type)
        raise ConfigurationError, "Invalid signer_type: #{signer_type}. Must be :sha1, :sha256, or :sha512"
      end

      true
    end

    def minio_configured?
      minio_endpoint && minio_bucket && minio_access_key && minio_secret_key
    end

    def minio_storage_config
      {
        "service" => "S3",
        "endpoint" => minio_endpoint,
        "access_key_id" => minio_access_key,
        "secret_access_key" => minio_secret_key,
        "bucket" => minio_bucket,
        "region" => minio_region,
        "force_path_style" => true
      }
    end
  end
end
