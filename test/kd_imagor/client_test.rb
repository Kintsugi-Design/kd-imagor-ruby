# frozen_string_literal: true

require "test_helper"

class KdImagor::ClientTest < Minitest::Test
  def setup
    super
    KdImagor.configure do |config|
      config.host = "https://imagor.example.com"
      config.secret = "test-secret"
      config.auto_webp = false
      config.minio_endpoint = "https://minio.example.com"
      config.minio_bucket = "test-bucket"
      config.minio_access_key = "test-access-key"
      config.minio_secret_key = "test-secret-key"
      config.minio_region = "us-east-1"
    end
    @client = KdImagor::Client.new
  end

  def test_s3_signer_returns_signer_instance
    signer = @client.s3_signer

    assert_instance_of KdImagor::S3Signer, signer
    assert_equal "https://minio.example.com", signer.endpoint
    assert_equal "test-access-key", signer.access_key
    assert_equal "test-secret-key", signer.secret_key
    assert_equal "us-east-1", signer.region
  end

  def test_s3_signer_raises_when_minio_not_configured
    KdImagor.configure do |config|
      config.host = "https://imagor.example.com"
      config.secret = "test-secret"
      config.minio_endpoint = nil
    end
    client = KdImagor::Client.new

    assert_raises(KdImagor::MinioError) do
      client.s3_signer
    end
  end

  def test_presigned_url_generates_get_url
    url = @client.presigned_url("path/to/image.jpg")

    assert_includes url, "https://minio.example.com/test-bucket/path/to/image.jpg"
    assert_includes url, "X-Amz-Algorithm=AWS4-HMAC-SHA256"
  end

  def test_presigned_url_with_custom_expiry
    url = @client.presigned_url("image.jpg", expires_in: 7200)

    assert_includes url, "X-Amz-Expires=7200"
  end

  def test_presigned_upload_url_generates_put_url
    url = @client.presigned_upload_url("uploads/new-image.jpg", content_type: "image/jpeg")

    assert_includes url, "https://minio.example.com/test-bucket/uploads/new-image.jpg"
    assert_includes url, "X-Amz-Algorithm=AWS4-HMAC-SHA256"
  end

  def test_url_with_string_source
    url = @client.url("https://example.com/image.jpg", width: 400, height: 300)

    assert_includes url, "400x300"
  end

  def test_url_with_nil_source
    url = @client.url(nil, width: 400, height: 300)

    assert_nil url
  end

  def test_thumbnail_generates_square_smart_crop
    url = @client.thumbnail("https://example.com/image.jpg", size: 100)

    assert_includes url, "100x100"
    assert_includes url, "smart"
  end

  def test_cover_generates_social_image
    url = @client.cover("https://example.com/image.jpg")

    assert_includes url, "1200x630"
    assert_includes url, "smart"
  end

  def test_srcset_generates_multiple_widths
    srcset = @client.srcset("https://example.com/image.jpg", widths: [320, 640])

    assert_includes srcset, "320w"
    assert_includes srcset, "640w"
  end
end
