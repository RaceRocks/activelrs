# frozen_string_literal: true

require_relative "active_lrs/version"
require_relative "active_lrs/railtie" if defined?(Rails::Railtie)
require "json"

# Top-level namespace for ActiveLrs, a Ruby client for xAPI/LRS interactions.
#
# This module provides configuration, autoloads core xAPI models, and
# includes helper methods to access LRS instances, statements, and client functionality.
module ActiveLrs
  # Autoload core xAPI models and components
  autoload :Xapi, "active_lrs/xapi"

  # Autoload configuration and client classes
  autoload :Configuration, "active_lrs/configuration"
  autoload :Statement, "active_lrs/statement"
  autoload :Client, "active_lrs/client"
  autoload :Error, "active_lrs/error"

  class << self
    # Access the global ActiveLrs configuration.
    #
    # @return [ActiveLrs::Configuration] the current configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure ActiveLrs using a block.
    #
    # @example Configure the default locale and remote LRS instances
    #   ActiveLrs.configure do |config|
    #     config.default_locale = "en-US"
    #     config.remote_lrs_instances = [{ "url" => "https://lrs.example.com", "username" => "user", "password" => "pass" }]
    #   end
    #
    # @yieldparam config [ActiveLrs::Configuration] the configuration object
    # @return [ActiveLrs::Configuration] the updated configuration
    def configure
      config = configuration
      yield(config) if block_given?
      config
    end

    # Freeze the configuration after Rails initialization.
    #
    # Typically called by ActiveLrs::Railtie to prevent further changes.
    #
    # @return [void]
    def finalize_configuration!
      configuration.freeze
    end
  end
end
