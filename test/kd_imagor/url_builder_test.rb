# frozen_string_literal: true

require "test_helper"

class KdImagor::UrlBuilderTest < Minitest::Test
  def setup
    super
    KdImagor.configure do |config|
      config.host = "https://imagor.example.com"
      config.secret = "test-secret"
      config.auto_webp = false
    end
    @builder = KdImagor::UrlBuilder.new
  end

  def test_build_with_dimensions
    url = @builder.build("https://example.com/image.jpg", width: 400, height: 300)
    assert_includes url, "400x300"
  end

  def test_build_with_smart_crop
    url = @builder.build("https://example.com/image.jpg", width: 200, height: 200, smart: true)
    assert_includes url, "smart"
  end

  def test_build_with_quality_filter
    url = @builder.build("https://example.com/image.jpg", width: 200, height: 200, quality: 75)
    assert_includes url, "quality(75)"
  end

  def test_build_with_format_filter
    url = @builder.build("https://example.com/image.jpg", width: 200, height: 200, format: :webp)
    assert_includes url, "format(webp)"
  end

  def test_build_with_grayscale
    url = @builder.build("https://example.com/image.jpg", width: 200, height: 200, grayscale: true)
    assert_includes url, "grayscale()"
  end
end
