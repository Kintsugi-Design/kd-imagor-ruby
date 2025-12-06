# KdImagor Ruby

Ruby gem for [Imagor](https://github.com/cshum/imagor) image processing with Rails and MinIO integration.

## Features

- **URL Generation** - Generate signed Imagor URLs with full filter support
- **View Helpers** - Rails view helpers for easy image rendering
- **Active Storage Integration** - Seamless integration with Rails Active Storage
- **MinIO Support** - Built-in configuration for MinIO S3-compatible storage
- **Responsive Images** - Automatic srcset generation

## Installation

Add to your Gemfile:

```ruby
gem "kd-imagor-ruby", git: "git@github.com:Kintsugi-Design/kd-imagor-ruby.git"
```

Then run:

```
bundle install
rails generate kd_imagor:install
```

## Configuration

Environment Variables

```
# Imagor server (required)
IMAGOR_URL=https://your-imagor.elest.io
IMAGOR_SECRET=your-secret-key  # Generate with: openssl rand -hex 32

# MinIO storage (optional)
MINIO_ENDPOINT=https://your-minio.elest.io
MINIO_ACCESS_KEY=your-access-key
MINIO_SECRET_KEY=your-secret-key
MINIO_BUCKET=your-bucket-name
```

## Initializer

The generator creates config/initializers/imagor.rb:

```ruby
KdImagor.configure do |config|
  # Imagor server
  config.host = ENV["IMAGOR_URL"]
  config.secret = ENV["IMAGOR_SECRET"]

  # Defaults
  config.default_quality = 80
  config.default_format = nil  # or :webp, :avif
  config.auto_webp = true

  # MinIO (optional)
  config.minio_endpoint = ENV["MINIO_ENDPOINT"]
  config.minio_bucket = ENV["MINIO_BUCKET"]
  config.minio_access_key = ENV["MINIO_ACCESS_KEY"]
  config.minio_secret_key = ENV["MINIO_SECRET_KEY"]
end
```

## Production Setup

Update config/environments/production.rb:

```ruby
config.active_storage.service = :minio
```

## Usage

View Helpers

```erb
<%# Basic image tag %>
<%= imagor_image_tag @user.avatar, width: 200, height: 200 %>

<%# With smart cropping %>
<%= imagor_image_tag @product.image, width: 300, height: 300, smart: true %>

<%# Responsive image %>
<%= imagor_image_tag @post.cover,
    width: 800,
    height: 400,
    responsive: true,
    sizes: "(max-width: 640px) 100vw, 800px",
    alt: "Post cover" %>

<%# Thumbnail %>
<%= imagor_thumbnail @user.avatar, size: 100 %>

<%# Avatar with fallback %>
<%= imagor_avatar @user.avatar, size: 64, name: @user.name %>

<%# Background image %>
<div style="<%= imagor_background_style @hero.image, width: 1920, height: 1080 %>">
</div>

<%# Just the URL %>
<%= imagor_url @product.image, width: 400, height: 300 %>

<%# Srcset for responsive images %>
<img src="..." srcset="<%= imagor_srcset @product.image %>">
```

## Processing Options

```ruby
# Dimensions
imagor_url(image, width: 400, height: 300)

# Fit modes
imagor_url(image, width: 400, height: 300, fit: "fit-in")   # Fit within bounds
imagor_url(image, width: 400, height: 300, fit: "stretch")  # Stretch to fill
imagor_url(image, width: 400, height: 300, fit: nil)        # Crop to fill

# Smart cropping (face detection)
imagor_url(image, width: 200, height: 200, smart: true)

# Quality
imagor_url(image, width: 400, quality: 75)

# Format conversion
imagor_url(image, width: 400, format: :webp)
imagor_url(image, width: 400, format: :avif)

# Filters
imagor_url(image, width: 400, grayscale: true)
imagor_url(image, width: 400, blur: 5)
imagor_url(image, width: 400, sharpen: 1)
imagor_url(image, width: 400, brightness: 10)
imagor_url(image, width: 400, contrast: 10)

# Background color (for transparent images)
imagor_url(image, width: 400, background: "ffffff")

# Round corners
imagor_url(image, width: 400, round: 20)

# Strip metadata
imagor_url(image, width: 400, strip_exif: true, strip_icc: true)

# Multiple options
imagor_url(image,
  width: 800,
  height: 600,
  smart: true,
  quality: 80,
  format: :webp,
  strip_exif: true
)
```

## Presets

```ruby
include KdImagor::Filters

# Thumbnails
imagor_url(image, **THUMB_SMALL)   # 50x50
imagor_url(image, **THUMB_MEDIUM)  # 100x100
imagor_url(image, **THUMB_LARGE)   # 200x200

# Avatars
imagor_url(image, **AVATAR_SM)     # 48x48
imagor_url(image, **AVATAR_MD)     # 64x64
imagor_url(image, **AVATAR_LG)     # 96x96

# Social media
imagor_url(image, **SOCIAL_FACEBOOK)   # 1200x630
imagor_url(image, **SOCIAL_TWITTER)    # 1200x675
imagor_url(image, **SOCIAL_INSTAGRAM)  # 1080x1080

# Quality presets
imagor_url(image, width: 400, **QUALITY_HIGH)      # quality: 85
imagor_url(image, width: 400, **WEB_OPTIMIZED)     # WebP, stripped metadata

# Combine presets
imagor_url(image, **Filters.merge(AVATAR_LG, GRAYSCALE))

In API Responses (Jbuilder)
# app/views/api/v1/users/_user.json.jbuilder
json.id user.id
json.name user.name

json.avatar do
  if user.avatar.attached?
    json.thumbnail imagor_url(user.avatar, width: 100, height: 100, smart: true)
    json.medium imagor_url(user.avatar, width: 300, height: 300, smart: true)
    json.large imagor_url(user.avatar, width: 600, height: 600, smart: true)
    json.original user.avatar.url(expires_in: 1.hour)
  end
end
```

## Direct Client Usage

```ruby
# Get the default client
client = KdImagor.client

# Or create a custom client
client = KdImagor::Client.new(config)

# Generate URLs
url = client.url("https://example.com/image.jpg", width: 400, height: 300)

# Convenience methods
thumbnail = client.thumbnail(source, size: 100)
cover = client.cover(source, width: 1200, height: 630)
srcset = client.srcset(source, widths: [320, 640, 1024])
```

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Rails App     │────▶│     MinIO       │────▶│     Imagor      │
│                 │     │   (Storage)     │     │  (Processing)   │
│  Upload ────────┼────▶│                 │     │                 │
│  Display ───────┼─────┼─────────────────┼────▶│                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## File Structure

```
lib/
├── kd-imagor-ruby.rb        # Main entry point
└── kd_imagor/
    ├── version.rb           # Gem version
    ├── configuration.rb     # Config DSL
    ├── client.rb            # URL generation client
    ├── url_builder.rb       # Imagor URL building
    ├── filters.rb           # Preset filters
    ├── railtie.rb           # Rails integration
    ├── view_helpers.rb      # View helpers
    └── generators/
        ├── install_generator.rb
        └── templates/
            └── imagor.rb.erb
```

## Development

```
git clone git@github.com:Kintsugi-Design/kd-imagor-ruby.git
cd kd-imagor-ruby
bundle install
bundle exec rake test
```

## License

MIT License - see LICENSE.txt