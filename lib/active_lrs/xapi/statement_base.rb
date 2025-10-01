# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents the base structure of an xAPI Statement.
    #
    # A Statement captures a single experience or action in xAPI. It includes
    # an `actor` (who did it), a `verb` (what they did), and an `object` (the target of the action).
    # Optionally, it may include a `result`, `context`, `timestamp`, and `attachments`.
    #
    # This class can serve as a parent or base class for xAPI Statements.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#422-statement
    class StatementBase
      # @return [Agent, Group] The actor performing the action.
      attr_accessor :actor

      # @return [Verb] The verb representing the action.
      attr_accessor :verb

      # @return [Activity, Agent, Group, StatementRef, SubStatement] The object of the statement.
      attr_accessor :object

      # @return [Result, nil] Optional result of the activity.
      attr_accessor :result

      # @return [Context, nil] Optional context providing additional info about the statement.
      attr_accessor :context

      # @return [Time, nil] The timestamp parsed as a Time object.
      attr_accessor :timestamp

      # @return [String, nil] The original timestamp string.
      attr_accessor :raw_timestamp

      # @return [Array<Attachment>, nil] Optional attachments associated with the statement.
      attr_accessor :attachments

      # Initializes a new StatementBase instance.
      #
      # @param attributes [Hash] A hash of statement attributes
      # @option attributes [Hash] "actor" The actor information. Determines if Agent or Group.
      # @option attributes [Hash] "verb" Verb information.
      # @option attributes [Hash] "object" Object information (Activity, Agent, Group, StatementRef, SubStatement).
      # @option attributes [Hash] "result" Result object.
      # @option attributes [Hash] "context" Context object.
      # @option attributes [String] "timestamp" ISO 8601 timestamp string.
      # @option attributes [Array<Hash>] "attachments" Array of attachments.
      #
      # @return [void]
      def initialize(attributes = {})
        self.actor = attributes["actor"]["member"] ? Xapi::Group.new(attributes["actor"]) : Xapi::Agent.new(attributes["actor"]) if attributes["actor"]
        self.verb = Xapi::Verb.new(attributes["verb"]) if attributes["verb"]
        if (object_node = attributes["object"])
          self.object = case object_node["objectType"]
          when "Group", "Agent"
            Xapi::Agent.new(object_node)
          when "StatementRef"
            Xapi::StatementRef.new(object_node)
          when "SubStatement"
            Xapi::SubStatement.new(object_node)
          else
            Xapi::Activity.new(object_node)
          end
        end
        self.result = Xapi::Result.new(attributes["result"]) if attributes["result"]
        self.context = Xapi::Context.new(attributes["context"]) if attributes["context"]
        self.timestamp = Time.parse(attributes["timestamp"]) if attributes["timestamp"]
        self.raw_timestamp = attributes["timestamp"] if attributes["timestamp"]
        self.attachments = attributes["attachments"]&.map { |attachment| Xapi::Attachment.new(attachment) } if attributes["attachments"]
      end

      # Converts the StatementBase into a hash suitable for serialization in an xAPI Statement.
      #
      # @example
      #   statement = ActiveLrs::Xapi::StatementBase.new(
      #     "actor" => { "mbox" => "mailto:alice@example.com" },
      #     "verb" => { "id" => "http://adlnet.gov/expapi/verbs/completed" },
      #     "object" => { "id" => "http://example.com/course/1" },
      #     "timestamp" => "2025-09-19T10:00:00Z"
      #   )
      #   statement.to_h
      #   # => {
      #   #   "actor" => { "objectType" => "Agent", "mbox" => "mailto:alice@example.com" },
      #   #   "verb" => { "id" => "http://adlnet.gov/expapi/verbs/completed" },
      #   #   "object" => { "id" => "http://example.com/course/1", "objectType" => "Activity" },
      #   #   "timestamp" => "2025-09-19T10:00:00Z"
      #   # }
      #
      # @return [Hash{String => Object}] A hash representation of the statement, including only present attributes.
      def to_h
        node = {}
        node["actor"] = actor.to_h
        node["verb"] = verb.to_h
        node["object"] = object.to_h
        node["result"] = result.to_h if result
        node["context"] = context.to_h if context
        node["timestamp"] = raw_timestamp || timestamp.strftime("%FT%T%:z") if timestamp
        node["attachments"] = attachments.map { |element| element.to_h } if attachments&.any?
        node
      end
    end
  end
end
