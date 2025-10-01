# frozen_string_literal: true

require "faraday"
require "forwardable"

module ActiveLrs
  # Provides an HTTP client for connecting to a remote Learning Record Store (LRS).
  # Uses Faraday for requests and supports Basic Authentication for secure access.
  #
  # @example
  #   client = ActiveLrs::Client.new(
  #     url: "https://lrs.example.com",
  #     username: "user",
  #     password: "pass"
  #   )
  #   statement = client.fetch_statement("some-statement-id")
  class Client
    extend Forwardable

    # @return [String] The base URL of the LRS
    attr_reader :base_url

    # @return [String] Username for Basic Authentication
    attr_reader :username

    # @return [String] Password for Basic Authentication
    attr_reader :password

    # @return [Faraday::Connection] The Faraday connection instance
    attr_reader :connection

    # Delegate HTTP verbs to the Faraday connection
    def_delegators :@connection, :get, :post, :put, :delete

    # Initializes a new LRS client.
    #
    # @param url [String] The base URL of the LRS
    # @param username [String] Username for Basic Authentication
    # @param password [String] Password for Basic Authentication
    # @param options [Hash] Optional Faraday connection options
    #
    # @return [void]
    def initialize(url:, username:, password:, options: {})
      @base_url = url
      @username = username
      @password = password
      @connection = build_connection(options)
    end

    # Builds the Faraday connection with standard xAPI headers and authentication.
    #
    # @param options [Hash] Optional Faraday connection options
    # @return [Faraday::Connection] Configured Faraday connection
    def build_connection(options)
      Faraday.new(url: base_url, **options) do |conn|
        conn.headers["X-Experience-API-Version"] = "2.0.0"
        conn.response :json
        conn.request :authorization, :basic, username, password
        conn.adapter Faraday.default_adapter
      end
    end

    # Fetches a single xAPI statement by ID.
    #
    # @param id [String] The ID of the statement to fetch
    # @return [Hash] Parsed statement from the LRS
    # @raise [ActiveLrs::HttpError] If the request fails
    def fetch_statement(id)
      response = connection.get("statements", statementId: id)
      handle_response(response)
    end

    # Fetches multiple xAPI statements with optional query parameters.
    #
    # @param params [Hash] Optional query parameters to filter statements
    # @return [Array<Hash>] Array of statements retrieved from the LRS
    # @raise [ActiveLrs::HttpError] If any request fails
    def fetch_statements(params = {})
      statements = []
      more = nil

      while more != false
        path = more || "xapi/statements"

        response = connection.get(path, params)
        response_body = handle_response(response)

        statements.concat(response_body.fetch("statements", []))

        more = response_body.fetch("more", false)
        more = false if more.nil? || more.empty?
      end

      statements
    end

    private

    # Handles the Faraday response and raises an error if the request failed.
    #
    # @param response [Faraday::Response] The HTTP response object
    # @return [Hash] Parsed response body if successful
    # @raise [ActiveLrs::HttpError] If the response indicates failure
    def handle_response(response)
      if response.success?
        response.body
      else
        raise ActiveLrs::HttpError.new(
          "LRS request failed (#{response.status}): #{response.body.inspect}",
          status: response.status,
          body: response.body
        )
      end
    end
  end
end
