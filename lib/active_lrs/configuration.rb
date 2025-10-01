module ActiveLrs
  # Stores configuration for xAPI/LRS interactions.
  #
  # This includes the xAPI profile server URL, default locale, and
  # remote LRS instances loaded from a YAML configuration file.
  class Configuration
    # @return [String] The URL of the xAPI profile server (default: "https://profiles.adlnet.gov/")
    attr_accessor :xapi_profile_server_url

    # @return [String] Default locale to use for xAPI statements (default: "en-US")
    attr_accessor :default_locale

    # @return [Array<Hash>] List of remote LRS endpoints loaded from config/remote_lrs.yml
    attr_accessor :remote_lrs_instances


    # Initializes a new Configuration instance.
    #
    # Loads the remote LRS endpoints from `config/remote_lrs.yml` if it exists.
    # If the file or the environment-specific section is missing, defaults to an empty array.
    #
    # @param env [String] The Rails environment or other environment name to load (default: ENV["RAILS_ENV"] || "development")
    #
    # @return [void]
    def initialize(env: ENV["RAILS_ENV"] || "development")
      @xapi_profile_server_url = "https://profiles.adlnet.gov/"
      @default_locale = "en-US"

      path = File.join(Dir.pwd, "config", "remote_lrs.yml")
      if File.exist?(path)
        raw  = ERB.new(File.read(path)).result
        yaml = YAML.safe_load(raw, aliases: true)
        env_config = yaml.fetch(env, {})
        @remote_lrs_instances = env_config["endpoints"] || []
      else
        @remote_lrs_instances = []
      end
    end
  end
end
