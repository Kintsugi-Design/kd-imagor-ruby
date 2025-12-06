# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-12-06

### Added
- Initial release
- Core `KD::Imagor::Client` for URL generation
- `KD::Imagor::UrlBuilder` with full Imagor filter support
- Rails view helpers (`imagor_image_tag`, `imagor_url`, `imagor_srcset`, etc.)
- Active Storage integration
- MinIO S3-compatible storage configuration
- Install generator (`bin/rails generate kd:imagor:install`)
- Preset filters for common use cases (thumbnails, avatars, social media)
- Configurable signature algorithms (SHA1, SHA256, SHA512)
- Auto WebP/AVIF conversion support
