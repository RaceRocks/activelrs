# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI Agent object.
    #
    # An Agent identifies an individual (person) associated with an xAPI
    # Statement. An Agent can be uniquely identified using one of the
    # Inverse Functional Identifier (IFI) fields: `mbox`, `mbox_sha1sum`,
    # `openid`, or `account`.
    #
    # This class is intended for use as the `actor` or `object` property
    # within an xAPI Statement.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4221-actor
    #   Section 4.2.2.1 "Actor" — see Agent object requirements
    class Agent
      # @return [String, nil] The full name of the Agent (human-readable).
      attr_accessor :name

      # @return [String, nil] A "mailto:" IRI identifying the Agent's email address.
      attr_accessor :mbox

      # @return [String, nil] The SHA1 hash of a "mailto:" IRI.
      attr_accessor :mbox_sha1_sum

      # @return [String, nil] An OpenID URI that uniquely identifies the Agent.
      attr_accessor :open_id

      # @return [AgentAccount, nil] An account object uniquely identifying the Agent
      #   within a given system.
      attr_accessor :account

      # @return [String] The object type. MUST be the literal string `"Agent"`.
      attr_accessor :object_type

      # Initializes a new Agent instance with optional attributes.
      #
      # @param attributes [Hash] a hash of agent attributes
      # @option attributes [String] "name" The human-readable name of the Agent.
      # @option attributes [String] "mbox" A "mailto:" IRI identifying the Agent's email address.
      # @option attributes [String] "mbox_sha1sum" The SHA1 hash of a "mailto:" IRI.
      # @option attributes [String] "openid" An OpenID URI that uniquely identifies the Agent.
      # @option attributes [Hash] "account" A hash representing the AgentAccount
      #   (keys: "homePage", "name").
      #
      # @return [void]
      def initialize(attributes = {})
        @object_type = "Agent"
        self.name = attributes["name"] if attributes["name"]
        self.mbox = attributes["mbox"] if attributes["mbox"]
        self.mbox_sha1_sum = attributes["mbox_sha1sum"] if attributes["mbox_sha1sum"]
        self.open_id = attributes["openid"] if attributes["openid"]
        self.account = Xapi::AgentAccount.new(attributes["account"]) if attributes["account"]
      end

      # Converts the Agent object into a hash representation suitable
      # for serialization in an xAPI Statement.
      #
      # @example
      #   agent = ActiveLrs::Xapi::Agent.new(
      #     "name" => "Jane Doe",
      #     "mbox" => "mailto:jane@example.com"
      #   )
      #   agent.to_h
      #   # => {
      #   #   "objectType" => "Agent",
      #   #   "name" => "Jane Doe",
      #   #   "mbox" => "mailto:jane@example.com"
      #   # }
      #
      # @return [Hash{String => String, Hash}] a hash including only the present attributes
      #   (`objectType`, `name`, `mbox`, `mbox_sha1sum`, `openid`, `account`)
      def to_h
        node = {}
        node["objectType"] = object_type
        node["name"] = name if name
        node["mbox"] = mbox if mbox
        node["mbox_sha1sum"] = mbox_sha1_sum if mbox_sha1_sum
        node["openid"] = open_id if open_id
        node["account"] = account.to_h if account
        node
      end
    end
  end
end
