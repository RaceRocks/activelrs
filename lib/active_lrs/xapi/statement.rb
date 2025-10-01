# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents a full xAPI Statement.
    #
    # A Statement captures a single learning experience or action. It consists
    # of an `actor` (who performed the action), a `verb` (the action), and an
    # `object` (the target of the action). Optionally, it may include `result`,
    # `context`, `timestamp`, `attachments`, and other metadata.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#422-statement
    class Statement < StatementBase
      # @return [Hash, nil] Raw xAPI payload from the LRS
      attr_accessor :raw_xapi

      # @return [String, nil] Optional UUID for the statement
      attr_accessor :id

      # @return [Time, nil] The timestamp when the xAPI statement was received by the LRS,
      #   parsed as a Time object.
      attr_accessor :stored

      # @return [String, nil] The original stored string from the xAPI statement
      attr_accessor :raw_stored

      # @return [Agent, nil] Authority responsible for the statement
      attr_accessor :authority

      # @return [String, nil] xAPI version string
      attr_accessor :version

      # @return [Boolean] True if the statement has been voided
      attr_accessor :voided

      # Initializes a new Statement.
      #
      # @param attributes [Hash] Hash containing statement attributes
      # @option attributes [String] "id" Optional UUID for the statement
      # @option attributes [Hash] "actor" Actor information (Agent or Group)
      # @option attributes [Hash] "verb" Verb information
      # @option attributes [Hash] "object" Object information (Activity, Agent, Group, StatementRef, SubStatement)
      # @option attributes [Hash] "result" Result object
      # @option attributes [Hash] "context" Context object
      # @option attributes [String] "timestamp" ISO 8601 timestamp
      # @option attributes [Array<Hash>] "attachments" Array of attachment objects
      # @option attributes [Hash] "authority" Authority information
      # @option attributes [String] "version" xAPI version string
      #
      # @return [void]
      def initialize(attributes = {})
        super(attributes)
        self.raw_xapi = attributes
        self.id = attributes["id"] if attributes["id"]
        self.stored =  Time.parse(attributes["stored"]) if attributes["stored"]
        self.raw_stored = attributes["stored"] if attributes["stored"]
        self.authority = Xapi::Agent.new(attributes["authority"]) if attributes["authority"]
        self.version = attributes["version"] if attributes["version"]
        self.voided = attributes["voided"] if attributes["voided"]
      end

      # Converts the Statement into a hash suitable for sending to an LRS.
      #
      # @example
      #   statement = ActiveLrs::Xapi::Statement.new(
      #     "id" => "123e4567-e89b-12d3-a456-426614174000",
      #     "actor" => { "mbox" => "mailto:alice@example.com" },
      #     "verb" => { "id" => "http://adlnet.gov/expapi/verbs/completed" },
      #     "object" => { "id" => "http://example.com/course/1" },
      #     "timestamp" => "2025-09-19T10:00:00Z"
      #   )
      #   statement.to_h
      #   # => {
      #   #   "id" => "123e4567-e89b-12d3-a456-426614174000",
      #   #   "actor" => { "objectType" => "Agent", "mbox" => "mailto:alice@example.com" },
      #   #   "verb" => { "id" => "http://adlnet.gov/expapi/verbs/completed" },
      #   #   "object" => { "id" => "http://example.com/course/1", "objectType" => "Activity" },
      #   #   "timestamp" => "2025-09-19T10:00:00Z"
      #   # }
      #
      # @return [Hash{String => Object}] A hash representation of the statement, including only present attributes.
      def to_h
        node = super
        node["id"] = id if id
        node["stored"] = raw_stored || stored.strftime("%FT%T%:z") if stored
        node["authority"] = authority.to_h if authority
        node["voided"] = voided if voided
        node["version"] = version.to_s if version
        node
      end
    end
  end
end
