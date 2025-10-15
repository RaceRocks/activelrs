module ActiveLrs
  # Stores configuration for xAPI/LRS interactions.
  #
  # This includes the xAPI profile server URL, and default locale.
  class Configuration
    # @return [String] The URL of the xAPI profile server (default: "https://profiles.adlnet.gov/")
    attr_accessor :xapi_profile_server_url

    # @return [String] Default locale to use for xAPI statements (default: "en-US")
    attr_accessor :default_locale

    # Initializes a new Configuration instance.
    #
    # @return [void]
    def initialize
      @xapi_profile_server_url = "https://profiles.adlnet.gov/"
      @default_locale = "en-US"
    end
  end
end
