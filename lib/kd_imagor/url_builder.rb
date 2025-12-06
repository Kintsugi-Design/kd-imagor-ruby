# frozen_string_literal: true

require "openssl"
require "base64"

module KdImagor
  class UrlBuilder
    VALID_FITS = ["fit-in", "stretch", nil].freeze
    VALID_HALIGNS = ["left", "center", "right"].freeze
    VALID_VALIGNS = ["top", "middle", "bottom"].freeze

    attr_reader :config

    def initialize(config = KdImagor.configuration)
      @config = config
    end

    def build(source_url, **options)
      path = build_path(source_url, **options)

      if config.unsafe_mode
        "#{config.host}/unsafe#{path}"
      else
        signature = generate_signature(path)
        "#{config.host}/#{signature}#{path}"
      end
    end

    def build_path(source_url, **options)
      parts = []

      parts << "trim" if options[:trim]

      if options[:crop]
        crop = options[:crop]
        if crop.is_a?(Hash)
          parts << "#{crop[:left]}x#{crop[:top]}:#{crop[:right]}x#{crop[:bottom]}"
        else
          parts << crop.to_s
        end
      end

      fit = options.fetch(:fit, config.default_fit)
      parts << fit if fit && VALID_FITS.include?(fit)

      width = options.fetch(:width, 0)
      height = options.fetch(:height, 0)
      parts << "#{width}x#{height}"

      halign = options[:halign]
      parts << halign if halign && VALID_HALIGNS.include?(halign)

      valign = options[:valign]
      parts << valign if valign && VALID_VALIGNS.include?(valign)

      parts << "smart" if options[:smart]

      filters = build_filters(**options)
      parts << "filters:#{filters}" if filters

      encoded_source = encode_source_url(source_url)

      "/#{parts.join("/")}/#{encoded_source}"
    end

    private

    def build_filters(**options)
      filters = []

      quality = options.fetch(:quality, config.default_quality)
      filters << "quality(#{quality})" if quality && quality != 100

      format = options.fetch(:format, config.default_format)
      filters << "format(#{format})" if format

      if options[:auto_format] != false
        if config.auto_avif && options[:avif] != false
          filters << "format(avif)"
        elsif config.auto_webp && options[:webp] != false
          filters << "format(webp)"
        end
      end

      filters << "blur(#{options[:blur]})" if options[:blur]
      filters << "sharpen(#{options[:sharpen]})" if options[:sharpen]
      filters << "brightness(#{options[:brightness]})" if options[:brightness]
      filters << "contrast(#{options[:contrast]})" if options[:contrast]
      filters << "saturation(#{options[:saturation]})" if options[:saturation]
      filters << "grayscale()" if options[:grayscale]
      filters << "background_color(#{options[:background]})" if options[:background]

      if options[:watermark]
        wm = options[:watermark]
        wm_parts = [wm[:url], wm.fetch(:x, "center"), wm.fetch(:y, "center"), wm.fetch(:alpha, 100)]
        filters << "watermark(#{wm_parts.join(",")})"
      end

      filters << "round_corner(#{options[:round]})" if options[:round]
      filters << "strip_exif()" if options[:strip_exif]
      filters << "strip_icc()" if options[:strip_icc]
      filters << options[:filters] if options[:filters]

      filters.empty? ? nil : filters.join(":")
    end

    def encode_source_url(url)
      Base64.urlsafe_encode64(url, padding: false)
    end

    def generate_signature(path)
      digest_class = case config.signer_type
      when :sha256 then OpenSSL::Digest::SHA256
      when :sha512 then OpenSSL::Digest::SHA512
      else OpenSSL::Digest::SHA1
      end

      hmac = OpenSSL::HMAC.digest(digest_class.new, config.secret, path)
      signature = Base64.urlsafe_encode64(hmac, padding: false)

      if config.signer_truncate && config.signer_truncate > 0
        signature[0, config.signer_truncate]
      else
        signature
      end
    end
  end
end
