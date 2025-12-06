# frozen_string_literal: true

require "rails/generators"

module KdImagor
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :minio, type: :boolean, default: true, desc: "Generate MinIO storage configuration"
      class_option :bucket, type: :string, default: nil, desc: "MinIO bucket name"

      desc "Install KdImagor configuration"

      def create_initializer
        template "imagor.rb.erb", "config/initializers/imagor.rb"
      end

      def update_storage_yml
        return unless options[:minio]

        storage_file = "config/storage.yml"
        if File.exist?(storage_file) && !File.read(storage_file).include?("minio:")
          append_to_file storage_file, minio_config
        end
      end

      def add_aws_sdk_gem
        return unless options[:minio]
        gem_line = 'gem "aws-sdk-s3", require: false'
        gemfile = "Gemfile"
        unless File.read(gemfile).include?("aws-sdk-s3")
          inject_into_file gemfile, "\n#{gem_line}\n", after: /gem ['"]rails['"].*\n/
        end
      end

      private

      def bucket_name
        options[:bucket] || "#{app_name.underscore.dasherize}-uploads"
      end

      def app_name
        Rails.application.class.module_parent_name rescue "myapp"
      end

      def minio_config
        <<~YAML

          minio:
            service: S3
            endpoint: <%= ENV.fetch("MINIO_ENDPOINT", "http://localhost:9000") %>
            access_key_id: <%= ENV["MINIO_ACCESS_KEY"] %>
            secret_access_key: <%= ENV["MINIO_SECRET_KEY"] %>
            bucket: <%= ENV.fetch("MINIO_BUCKET", "#{bucket_name}") %>
            region: <%= ENV.fetch("MINIO_REGION", "us-east-1") %>
            force_path_style: true
        YAML
      end
    end
  end
end
