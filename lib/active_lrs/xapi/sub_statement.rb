# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI SubStatement object.
    #
    # A SubStatement is like a normal Statement but **cannot have its own `id`, `authority`, or `stored` information**.
    # SubStatements are typically used as the `object` property inside another Statement or SubStatement.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4223-object
    #   Section 4.2.2.3 "Object" - see the "Object As Sub-Statement" subsection
    class SubStatement < StatementBase
      # @return [String] The object type. MUST be the literal string `"SubStatement"`.
      attr_accessor :object_type

      # Initializes a new SubStatement.
      #
      # @param attributes [Hash] Attributes for the SubStatement
      # @option attributes [Hash] "actor" Actor information (Agent or Group)
      # @option attributes [Hash] "verb" Verb information
      # @option attributes [Hash] "object" Object information (Activity, Agent, Group, StatementRef, SubStatement)
      # @option attributes [Hash] "result" Optional result of the activity
      # @option attributes [Hash] "context" Optional context providing additional info
      # @option attributes [String] "timestamp" ISO 8601 timestamp
      #
      # @return [void]
      def initialize(attributes = {})
        @object_type = "SubStatement"
        super(attributes)
      end

      # Converts the SubStatement into a hash suitable for inclusion as an object in another Statement.
      #
      # @example
      #   sub = ActiveLrs::Xapi::SubStatement.new(
      #     "actor" => { "mbox" => "mailto:bob@example.com" },
      #     "verb" => { "id" => "http://adlnet.gov/expapi/verbs/attempted" },
      #     "object" => { "id" => "http://example.com/course/2" }
      #   )
      #   sub.to_h
      #   # => {
      #   #   "objectType" => "SubStatement",
      #   #   "actor" => { "objectType" => "Agent", "mbox" => "mailto:bob@example.com" },
      #   #   "verb" => { "id" => "http://adlnet.gov/expapi/verbs/attempted" },
      #   #   "object" => { "id" => "http://example.com/course/2", "objectType" => "Activity" }
      #   # }
      #
      # @return [Hash{String => Object}] A hash representation of the SubStatement
      def to_h
        node = super
        node["objectType"] = object_type
        node
      end
    end
  end
end
