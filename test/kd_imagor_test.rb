# frozen_string_literal: true

require "test_helper"

class KdImagorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil KdImagor::VERSION
  end

  def test_configure_yields_configuration
    yielded = nil
    KdImagor.configure do |config|
      config.host = "https://imagor.example.com"
      config.secret = "test-secret"
      yielded = config
    end

    assert_kind_of KdImagor::Configuration, yielded
  end

  def test_configure_allows_setting_host
    KdImagor.configure do |config|
      config.host = "https://imagor.example.com"
      config.secret = "test-secret"
    end

    assert_equal "https://imagor.example.com", KdImagor.configuration.host
  end

  def test_url_generates_signed_url
    KdImagor.configure do |config|
      config.host = "https://imagor.example.com"
      config.secret = "test-secret"
    end

    url = KdImagor.url("https://example.com/image.jpg", width: 200, height: 200)

    assert url.start_with?("https://imagor.example.com/")
    assert_includes url, "200x200"
  end

  def test_url_returns_nil_for_nil_source
    KdImagor.configure do |config|
      config.host = "https://imagor.example.com"
      config.secret = "test-secret"
    end

    assert_nil KdImagor.url(nil, width: 200, height: 200)
  end
end
