# frozen_string_literal: true

require "net/http"
require "uri"

module KdImagor
  class Client
    attr_reader :config, :url_builder

    def initialize(config = KdImagor.configuration)
      @config = config
      @url_builder = UrlBuilder.new(config)
    end

    def s3_signer
      raise MinioError, "MinIO is not configured" unless config.minio_configured?

      @s3_signer ||= S3Signer.new(
        endpoint: config.minio_endpoint,
        access_key: config.minio_access_key,
        secret_key: config.minio_secret_key,
        region: config.minio_region
      )
    end

    def presigned_url(key, expires_in: nil)
      expires_in ||= config.presigned_url_expires_in || 3600
      s3_signer.presigned_get_url(config.minio_bucket, key, expires_in: expires_in)
    end

    def presigned_upload_url(key, content_type: nil, expires_in: nil)
      expires_in ||= config.presigned_url_expires_in || 3600
      s3_signer.presigned_put_url(config.minio_bucket, key, content_type: content_type, expires_in: expires_in)
    end

    def imagor_healthy?(timeout: nil)
      timeout ||= config.health_check_timeout || 5
      uri = URI.parse(config.host)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = timeout
      http.read_timeout = timeout
      response = http.head("/")
      response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
    rescue
      false
    end

    def minio_healthy?(timeout: nil)
      return false unless config.minio_configured?

      timeout ||= config.health_check_timeout || 5
      uri = URI.parse("#{config.minio_endpoint}/#{config.minio_bucket}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = timeout
      http.read_timeout = timeout
      response = http.head(uri.path)
      response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
    rescue
      false
    end

    def url(source, width: 0, height: 0, **options)
      source_url = resolve_source_url(source)
      return nil if source_url.nil?

      url_builder.build(source_url, width: width, height: height, **options)
    end

    def srcset(source, widths: [320, 640, 768, 1024, 1280], **options)
      source_url = resolve_source_url(source)
      return nil if source_url.nil?

      srcset_options = options.merge(fit: "fit-in", height: 0)

      widths.map do |w|
        img_url = url_builder.build(source_url, width: w, **srcset_options)
        "#{img_url} #{w}w"
      end.join(", ")
    end

    def thumbnail(source, size: 100, **options)
      url(source, width: size, height: size, fit: nil, smart: true, **options)
    end

    def cover(source, width: 1200, height: 630, **options)
      url(source, width: width, height: height, fit: nil, smart: true, **options)
    end

    private

    def resolve_source_url(source)
      case source
      when String
        source
      when nil
        nil
      else
        if source.respond_to?(:attached?) && source.attached?
          resolve_active_storage_url(source)
        elsif source.respond_to?(:url)
          source.url
        elsif source.respond_to?(:to_s)
          source.to_s
        end
      end
    end

    def resolve_active_storage_url(attachment)
      expires_in = config.presigned_url_expires_in || 3600

      if attachment.respond_to?(:url)
        attachment.url(expires_in: expires_in)
      elsif attachment.respond_to?(:service_url)
        attachment.service_url(expires_in: expires_in)
      end
    rescue => e
      raise AttachmentError, "Failed to resolve ActiveStorage URL: #{e.message}"
    end
  end
end
