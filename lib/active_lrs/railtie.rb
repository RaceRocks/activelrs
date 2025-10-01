# frozen_string_literal: true

module ActiveLrs
  # Rails integration for ActiveLrs.
  #
  # This Railtie automatically configures ActiveLrs during Rails initialization
  # and freezes the configuration after the framework has fully initialized.
  #
  # @example
  #   # Simply include the gem in your Rails app
  #   # ActiveLrs will be configured automatically on boot
  class Railtie < Rails::Railtie
    # Configure ActiveLrs during Rails initialization
    initializer "active_lrs.configure" do
      ActiveLrs.configure
    end

    # Freeze configuration after Rails finishes initializing
    config.after_initialize do
      ActiveLrs.finalize_configuration!
    end
  end
end
