# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2025-12-08

### Added
- `S3Signer` class with pure Ruby S3 Signature V4 implementation (no aws-sdk dependency)
- `Client#presigned_url` for generating MinIO presigned GET URLs
- `Client#presigned_upload_url` for generating presigned PUT URLs (direct browser uploads)
- `Client#imagor_healthy?` and `Client#minio_healthy?` health check methods
- New exception classes: `ConnectionError`, `AttachmentError`, `MinioError`
- `health_check_timeout` configuration option

### Changed
- `presigned_url_expires_in` now defaults to 3600 (integer) instead of `1.hour` for standalone Ruby compatibility
- `resolve_active_storage_url` now raises `AttachmentError` instead of silently returning nil

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
