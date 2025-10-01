# frozen_string_literal: true

module ActiveLrs
  # Base class for all ActiveLrs custom errors.
  #
  # @example
  #   raise ActiveLrs::Error, "Something went wrong"
  class Error < StandardError; end

  # Raised when an HTTP request to the LRS fails (non-2xx response).
  #
  # Provides access to the HTTP status code and response body.
  #
  # @!attribute [r] status
  #   @return [Integer, nil] The HTTP status code of the failed request
  #
  # @!attribute [r] body
  #   @return [Object, nil] The response body returned by the LRS
  #
  # @example
  #   raise ActiveLrs::HttpError.new("LRS error", status: 500, body: { "error" => "Internal" })
  class HttpError < Error
    attr_reader :status, :body

    # Initializes a new HttpError.
    #
    # @param message [String, nil] Error message
    # @param status [Integer, nil] HTTP status code
    # @param body [Object, nil] HTTP response body
    def initialize(message = nil, status: nil, body: nil)
      super(message || "HTTP request failed")
      @status = status
      @body   = body
    end
  end

  # Raised when parsing or interpreting xAPI JSON fails.
  #
  # @example
  #   raise ActiveLrs::ParseError, "Invalid xAPI statement"
  class ParseError < Error; end

  # Raised when required configuration is missing.
  #
  # @example
  #   raise ActiveLrs::ConfigurationError, "Missing LRS credentials"
  class ConfigurationError < Error; end
end
