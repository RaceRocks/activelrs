# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI Group object.
    #
    # A Group is a special type of xAPI Actor that identifies multiple Agents.
    # Groups can be "identified" (with their own IFIs such as `mbox`, `mbox_sha1sum`,
    # `openid`, or `account`) or "anonymous" (without an IFI, containing only members).
    #
    # This class is intended for use as the `actor`, `instructor`, or `team`
    # property within an xAPI Statement.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4221-actor
    #   Section 4.2.2.1 "Actor" — see Group object requirements
    class Group < Agent
      # @!attribute [rw] object_type
      #   @return [String] The object type. MUST be the literal string `"Group"`.

      # @return [Array<Agent>, nil] An array of Agents that are members of the Group.
      attr_accessor :members

      # Initializes a new Group instance with optional attributes.
      #
      # @param attributes [Hash] a hash of group attributes
      # @option attributes [String] "name" The human-readable name of the Group.
      # @option attributes [String] "mbox" A "mailto:" IRI identifying the Group's email address.
      # @option attributes [String] "mbox_sha1sum" The SHA1 hash of a "mailto:" IRI.
      # @option attributes [String] "openid" An OpenID URI that uniquely identifies the Group.
      # @option attributes [Hash] "account" A hash representing the Group's AgentAccount.
      # @option attributes [Array<Hash>] "member" An array of Agent hashes representing members.
      #
      # @return [void]
      def initialize(attributes = {})
        super(attributes)

        @object_type = "Group"
        if attributes["member"]
          @members = []
          attributes["member"].each do |member|
            members << Agent.new(member)
          end
        end
      end

      # Converts the Group object into a hash representation suitable
      # for serialization in an xAPI Statement.
      #
      # @example
      #   group = ActiveLrs::Xapi::Group.new(
      #     "name" => "Team A",
      #     "member" => [
      #       { "mbox" => "mailto:alice@example.com" },
      #       { "mbox" => "mailto:bob@example.com" }
      #     ]
      #   )
      #   group.to_h
      #   # => {
      #   #   "objectType" => "Group",
      #   #   "name" => "Team A",
      #   #   "member" => [
      #   #     { "objectType" => "Agent", "mbox" => "mailto:alice@example.com" },
      #   #     { "objectType" => "Agent", "mbox" => "mailto:bob@example.com" }
      #   #   ]
      #   # }
      #
      # @return [Hash{String => String, Array<Hash>}] a hash including only the present attributes
      def to_h
        node = super
        node["objectType"] = object_type
        node["member"] = members.map { |member| member.to_h } if members&.any?
        node
      end
    end
  end
end
