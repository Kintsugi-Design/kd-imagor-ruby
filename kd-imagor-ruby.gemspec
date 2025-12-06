# frozen_string_literal: true

require_relative "lib/kd_imagor/version"

Gem::Specification.new do |spec|
  spec.name = "kd-imagor-ruby"
  spec.version = KdImagor::VERSION
  spec.authors = ["Rudzainy Rahman"]
  spec.email = ["rudzainy@gmail.com"]

  spec.summary = "Ruby client for Imagor image processing server with Rails and MinIO integration"
  spec.description = "A comprehensive Ruby gem for integrating Imagor image processing server with Rails applications. " \
                     "Includes Active Storage helpers, view helpers, and MinIO S3-compatible storage configuration."
  spec.homepage = "https://github.com/Kintsugi-Design/kd-imagor-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 7.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "standard", "~> 1.3"
end
