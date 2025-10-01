# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI AgentAccount object.
    #
    # An AgentAccount is used to uniquely identify an agent on a system
    # via a combination of `name` and `homePage`. This is typically used
    # when the `account` property is part of an Agent object.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4221-actor
    #   Section 4.2.2.1 "Actor" — see "Accont" subsection
    class AgentAccount
      # @return [String, nil] The homepage of the system where the agent account exists.
      attr_accessor :homePage

      # @return [String, nil] The unique identifier (name) for the agent within the system.
      attr_accessor :name

      # Initializes a new AgentAccount instance with optional attributes.
      #
      # @param attributes [Hash] a hash of account attributes
      # @option attributes [String] "name" The unique identifier for the agent.
      # @option attributes [String] "homePage" The homepage of the system where the agent account exists.
      #
      # @return [void]
      def initialize(attributes = {})
        self.name = attributes["name"] if attributes["name"]
        self.homePage = attributes["homePage"] if attributes["homePage"]
      end

      # Converts the AgentAccount object into a hash representation suitable
      # for serialization in an xAPI Statement.
      #
      # @example
      #   account = ActiveLrs::Xapi::AgentAccount.new(
      #     "name" => "user123",
      #     "homePage" => "https://example.com"
      #   )
      #   account.to_h
      #   # => { "name" => "user123", "homePage" => "https://example.com" }
      #
      # @return [Hash{String => String}] a hash including only the present attributes
      def to_h
        node = {}
        node["name"] = name if name
        node["homePage"] = homePage if homePage
        node
      end
    end
  end
end
