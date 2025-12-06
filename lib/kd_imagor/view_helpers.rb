# frozen_string_literal: true

module KdImagor
  module ViewHelpers
    def imagor_url(source, width: 0, height: 0, **options)
      KdImagor.url(source, width: width, height: height, **options)
    end

    def imagor_srcset(source, widths: [320, 640, 768, 1024, 1280], **options)
      KdImagor.srcset(source, widths: widths, **options)
    end

    def imagor_image_tag(source, width: 0, height: 0, **options)
      return nil if source.nil?
      return nil if source.respond_to?(:attached?) && !source.attached?

      html_options = options.extract!(:alt, :class, :id, :style, :data, :loading, :decoding, :sizes, :title)
      responsive = options.delete(:responsive)
      srcset_widths = options.delete(:srcset_widths) || [320, 640, 768, 1024, 1280]

      url = imagor_url(source, width: width, height: height, **options)
      return nil if url.nil?

      html_attrs = html_options.dup
      html_attrs[:src] = url
      html_attrs[:width] = width if width > 0
      html_attrs[:height] = height if height > 0
      html_attrs[:loading] ||= "lazy"

      if responsive
        srcset = imagor_srcset(source, widths: srcset_widths, **options)
        html_attrs[:srcset] = srcset if srcset
        html_attrs[:sizes] ||= "(max-width: #{width}px) 100vw, #{width}px" if width > 0
      end

      tag.img(**html_attrs)
    end

    def imagor_thumbnail(source, size: 100, **options)
      imagor_image_tag(source, width: size, height: size, fit: nil, smart: true, **options)
    end

    def imagor_avatar(source, size: 64, fallback: nil, **options)
      if source.nil? || (source.respond_to?(:attached?) && !source.attached?)
        if fallback
          tag.img(src: fallback, width: size, height: size, **options.slice(:alt, :class, :id))
        else
          name = options.delete(:name) || "?"
          ui_avatar_url = "https://ui-avatars.com/api/?name=#{ERB::Util.url_encode(name)}&size=#{size}&background=random"
          tag.img(src: ui_avatar_url, width: size, height: size, **options.slice(:alt, :class, :id))
        end
      else
        imagor_thumbnail(source, size: size, **options)
      end
    end

    def imagor_background_style(source, width: 0, height: 0, **options)
      url = imagor_url(source, width: width, height: height, **options)
      return "" if url.nil?
      "background-image: url('#{url}')"
    end

    def imagor_enabled?
      KdImagor.configuration.host.present?
    rescue StandardError
      false
    end
  end
end
