require "rails/generators"

module ActiveLrs
  # Rails generator to install the ActiveLrs configuration file.
  #
  # This generator copies the `remote_lrs.yml` template into the Rails
  # application's `config` directory so that remote LRS endpoints can be configured.
  #
  # @example Run the generator from the Rails app root
  #   rails generate active_lrs:install
  class InstallGenerator < Rails::Generators::Base
    # Directory where the generator templates are located
    source_root File.expand_path("templates", __dir__)

    # Description displayed when running `rails generate`
    desc "Creates a remote_lrs.yml config file in your Rails app"

    # Copies the `remote_lrs.yml` template to the application's config folder
    #
    # @return [void]
    def copy_config
      template "remote_lrs.yml", "config/remote_lrs.yml"
    end
  end
end
