# frozen_string_literal: true

require "faraday"
require "forwardable"

module ActiveLrs
  class Connection
    extend Forwardable

    # @return [String] The name of the LRS
    attr_reader :name

    # @return [String] The base URL of the LRS
    attr_reader :url

    # @return [String] Username for Basic Authentication
    attr_reader :username

    # @return [String] Password for Basic Authentication
    attr_reader :password

    # @return [String] The xAPI version to use
    attr_reader :version

    # @return [String] The attribute path for pagination (e.g., "more" or "pagination.more")
    attr_reader :more_attribute

    # @return [Faraday::Connection] The Faraday Connection instance
    attr_reader :faraday_connection

    # Delegate HTTP verbs to the Faraday connection
    def_delegators :faraday_connection, :get, :post, :put, :delete

    # Initializes a new LRS Connection.
    #
    # @param name [String] The name of the LRS
    # @param url [String] The base URL of the LRS
    # @param username [String] Username for Basic Authentication
    # @param password [String] Password for Basic Authentication
    # @param more_attribute [String] Attribute path for pagination URL (defaults to "more")
    # @param version [String] The xAPI version (defaults to "2.0.0")
    #
    # @return [void]
    def initialize(name:, url:, username:, password:, version: nil, more_attribute: nil)
      @name = name
      @url = url
      @username = username
      @password = password
      @version = version || "2.0.0"
      @more_attribute = more_attribute || "more"
    end

    def faraday_connection
      @faraday_connection ||= Faraday.new(url: url) do |conn|
        conn.headers["X-Experience-API-Version"] = version
        conn.response :json
        conn.request :authorization, :basic, username, password
      end
    end

    # Fetches a single xAPI statement by ID.
    #
    # @param id [String] The ID of the statement to fetch
    # @return [Hash] Parsed statement from the LRS
    # @raise [ActiveLrs::HttpError] If the request fails
    def fetch_statement(id)
      response = faraday_connection.get("statements", statementId: id)
      validate_response_and_return_body(response)
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

        response = faraday_connection.get(path, params)
        response_body = validate_response_and_return_body(response)

        statements.concat(response_body.fetch("statements", []))

        more = dig_attribute(response_body, more_attribute)
        more = false if more.nil? || more.empty?
      end

      statements
    end

    def self.parse(hash_connection)
      new(
        name: hash_connection["name"],
        url: hash_connection["url"],
        username: hash_connection["username"],
        password: hash_connection["password"],
        version: hash_connection["version"],
        more_attribute: hash_connection["more_attribute"]
      )
    end

    private

    # Digs into a hash using a dot-separated attribute path.
    #
    # @param hash [Hash] The hash to dig into
    # @param path [String] Dot-separated attribute path (e.g., "more" or "pagination.more")
    # @return [Object, nil] The value at the path or nil if not found
    def dig_attribute(hash, path)
      path.split(".").reduce(hash) do |current, key|
        current.is_a?(Hash) ? current[key] : nil
      end
    rescue StandardError
      nil
    end

    # Validates the Faraday response and raises an error if the request failed.
    #
    # @param response [Faraday::Response] The HTTP response object
    # @return [Hash] Parsed response body if successful
    # @raise [ActiveLrs::HttpError] If the response indicates failure
    def validate_response_and_return_body(response)
      return response.body if response.success?

      raise ActiveLrs::HttpError.new(
        "LRS request failed (#{response.status}): #{response.body.inspect}",
        status: response.status,
        body: response.body
      )
    end
  end
end
