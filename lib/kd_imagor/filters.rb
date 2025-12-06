# frozen_string_literal: true

module KdImagor
  module Filters
    QUALITY_LOW = { quality: 60 }.freeze
    QUALITY_MEDIUM = { quality: 75 }.freeze
    QUALITY_HIGH = { quality: 85 }.freeze
    QUALITY_LOSSLESS = { quality: 100 }.freeze

    FORMAT_WEBP = { format: :webp }.freeze
    FORMAT_AVIF = { format: :avif }.freeze
    FORMAT_JPEG = { format: :jpeg }.freeze
    FORMAT_PNG = { format: :png }.freeze

    GRAYSCALE = { grayscale: true }.freeze
    BLUR_LIGHT = { blur: 2 }.freeze
    BLUR_MEDIUM = { blur: 5 }.freeze
    BLUR_HEAVY = { blur: 10 }.freeze
    SHARPEN = { sharpen: 1 }.freeze

    SOCIAL_FACEBOOK = { width: 1200, height: 630, fit: nil, smart: true }.freeze
    SOCIAL_TWITTER = { width: 1200, height: 675, fit: nil, smart: true }.freeze
    SOCIAL_INSTAGRAM = { width: 1080, height: 1080, fit: nil, smart: true }.freeze
    SOCIAL_LINKEDIN = { width: 1200, height: 627, fit: nil, smart: true }.freeze

    THUMB_SMALL = { width: 50, height: 50, fit: nil, smart: true }.freeze
    THUMB_MEDIUM = { width: 100, height: 100, fit: nil, smart: true }.freeze
    THUMB_LARGE = { width: 200, height: 200, fit: nil, smart: true }.freeze

    AVATAR_XS = { width: 32, height: 32, fit: nil, smart: true }.freeze
    AVATAR_SM = { width: 48, height: 48, fit: nil, smart: true }.freeze
    AVATAR_MD = { width: 64, height: 64, fit: nil, smart: true }.freeze
    AVATAR_LG = { width: 96, height: 96, fit: nil, smart: true }.freeze
    AVATAR_XL = { width: 128, height: 128, fit: nil, smart: true }.freeze

    WEB_OPTIMIZED = { quality: 80, format: :webp, strip_exif: true, strip_icc: true }.freeze
    RETINA_2X = { quality: 75, format: :webp }.freeze

    class << self
      def merge(*presets)
        presets.reduce({}) { |acc, preset| acc.merge(preset) }
      end

      def preset(name)
        const_name = name.to_s.upcase
        const_get(const_name) if const_defined?(const_name)
      end
    end
  end
end
