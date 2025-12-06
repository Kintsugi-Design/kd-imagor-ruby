# frozen_string_literal: true

require_relative "view_helpers"

module KdImagor
  class Railtie < Rails::Railtie
    initializer "kd_imagor.configure" do |app|
      KdImagor.configure {} if KdImagor.configuration.host.nil? && ENV["IMAGOR_URL"].present?
    end

    initializer "kd_imagor.view_helpers" do
      ActiveSupport.on_load(:action_view) do
        include KdImagor::ViewHelpers
      end
    end

    initializer "kd_imagor.action_controller" do
      ActiveSupport.on_load(:action_controller) do
        helper KdImagor::ViewHelpers if respond_to?(:helper)
      end
    end

    initializer "kd_imagor.jbuilder" do
      ActiveSupport.on_load(:jbuilder) do
        include KdImagor::ViewHelpers
      end if defined?(Jbuilder)
    end

    generators do
      require_relative "generators/install_generator"
    end
  end
end
