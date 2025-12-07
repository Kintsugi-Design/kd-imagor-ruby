# frozen_string_literal: true

require "test_helper"

class KdImagor::S3SignerTest < Minitest::Test
  def setup
    super
    @signer = KdImagor::S3Signer.new(
      endpoint: "https://minio.example.com",
      access_key: "test-access-key",
      secret_key: "test-secret-key",
      region: "us-east-1"
    )
  end

  def test_presigned_get_url_generates_valid_url
    url = @signer.presigned_get_url("my-bucket", "path/to/image.jpg")

    assert_includes url, "https://minio.example.com/my-bucket/path/to/image.jpg"
    assert_includes url, "X-Amz-Algorithm=AWS4-HMAC-SHA256"
    assert_includes url, "X-Amz-Credential="
    assert_includes url, "X-Amz-Date="
    assert_includes url, "X-Amz-Expires=3600"
    assert_includes url, "X-Amz-SignedHeaders=host"
    assert_includes url, "X-Amz-Signature="
  end

  def test_presigned_get_url_with_custom_expiry
    url = @signer.presigned_get_url("my-bucket", "image.jpg", expires_in: 7200)

    assert_includes url, "X-Amz-Expires=7200"
  end

  def test_presigned_put_url_generates_valid_url
    url = @signer.presigned_put_url("my-bucket", "path/to/upload.jpg", content_type: "image/jpeg")

    assert_includes url, "https://minio.example.com/my-bucket/path/to/upload.jpg"
    assert_includes url, "X-Amz-Algorithm=AWS4-HMAC-SHA256"
    assert_includes url, "X-Amz-SignedHeaders="
    assert_includes url, "X-Amz-Signature="
  end

  def test_presigned_url_encodes_special_characters_in_key
    url = @signer.presigned_get_url("my-bucket", "path/to/image with spaces.jpg")

    assert_includes url, "image%20with%20spaces.jpg"
  end

  def test_presigned_url_handles_leading_slash_in_key
    url1 = @signer.presigned_get_url("my-bucket", "/image.jpg")
    url2 = @signer.presigned_get_url("my-bucket", "image.jpg")

    assert_includes url1, "/my-bucket/image.jpg"
    assert_includes url2, "/my-bucket/image.jpg"
  end

  def test_raises_error_without_endpoint
    signer = KdImagor::S3Signer.new(
      endpoint: nil,
      access_key: "key",
      secret_key: "secret"
    )

    assert_raises(KdImagor::MinioError) do
      signer.presigned_get_url("bucket", "key")
    end
  end

  def test_raises_error_without_access_key
    signer = KdImagor::S3Signer.new(
      endpoint: "https://minio.example.com",
      access_key: nil,
      secret_key: "secret"
    )

    assert_raises(KdImagor::MinioError) do
      signer.presigned_get_url("bucket", "key")
    end
  end

  def test_raises_error_without_secret_key
    signer = KdImagor::S3Signer.new(
      endpoint: "https://minio.example.com",
      access_key: "key",
      secret_key: nil
    )

    assert_raises(KdImagor::MinioError) do
      signer.presigned_get_url("bucket", "key")
    end
  end

  def test_default_region_is_us_east_1
    signer = KdImagor::S3Signer.new(
      endpoint: "https://minio.example.com",
      access_key: "key",
      secret_key: "secret"
    )

    assert_equal "us-east-1", signer.region
  end

  def test_custom_region
    signer = KdImagor::S3Signer.new(
      endpoint: "https://minio.example.com",
      access_key: "key",
      secret_key: "secret",
      region: "eu-west-1"
    )

    assert_equal "eu-west-1", signer.region
  end

  def test_signature_includes_region_in_credential
    url = @signer.presigned_get_url("bucket", "key")

    assert_includes url, "us-east-1"
  end
end
