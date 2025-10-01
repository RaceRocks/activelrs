# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI Context object.
    #
    # A Context object provides additional information about the
    # circumstances in which a Statement occurred. This may include
    # registration identifiers, instructor, team, contextual activities,
    # platform, language, revision, and extensions.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4225-context
    #   Section 4.2.2.5 "Context"
    class Context
      # @return [String, nil] A UUID identifying a registration (a series of Statements).
      attr_accessor :registration

      # @return [Agent, Group, nil] An Agent or Group representing the instructor.
      attr_accessor :instructor

      # @return [Group, nil] A Group of Agents that participated in the Statement.
      attr_accessor :team

      # @return [ContextActivity, nil] A set of related Activities providing context
      #   (e.g., parent course, grouping, category, or other).
      attr_accessor :context_activities

      # @return [String, nil] Revision/version information associated with the Activity.
      attr_accessor :revision

      # @return [String, nil] A description of the system or platform used in the experience.
      attr_accessor :platform

      # @return [String, nil] The language code (RFC 5646) in which the experience occurred.
      attr_accessor :language

      # @return [StatementRef, nil] A reference to another Statement. Serialized as:
      #   { "objectType" => "StatementRef", "id" => "<UUID>" }.
      attr_accessor :statement

      # @return [Hash{String => Object}, nil] A map of custom key/value pairs providing additional context data.
      attr_accessor :extensions

      # Initializes a new Context instance with optional attributes.
      #
      # @param attributes [Hash] a hash of context attributes
      # @option attributes [String] "registration" UUID string identifying a registration.
      # @option attributes [Hash] "instructor" A hash representing an Agent or Group.
      # @option attributes [Hash] "team" A hash representing a Group of Agents.
      # @option attributes [Hash] "contextActivities" A hash of ContextActivity arrays.
      # @option attributes [String] "revision" Revision/version of the Activity.
      # @option attributes [String] "platform" System/platform identifier.
      # @option attributes [String] "language" Language code per RFC 5646.
      # @option attributes [Hash] "statement" A StatementRef hash (keys: "objectType" => "StatementRef", "id" => "<UUID>").
      # @option attributes [Hash] "extensions" Arbitrary key/value pairs for extended context.
      #
      # @return [void]
      def initialize(attributes = {})
        self.registration = attributes["registration"] if attributes["registration"]
        self.instructor = attributes["instructor"]["member"] ? Xapi::Group.new(attributes["instructor"]) : Xapi::Agent.new(attributes["instructor"]) if attributes["instructor"]
        self.team = Xapi::Group.new(attributes["team"]) if attributes["team"]
        self.context_activities = Xapi::ContextActivities.new(attributes["contextActivities"]) if attributes["contextActivities"]
        self.revision = attributes["revision"] if attributes["revision"]
        self.platform = attributes["platform"] if attributes["platform"]
        self.language = attributes["language"] if attributes["language"]
        self.statement = Xapi::StatementRef.new(attributes["statement"]) if attributes["statement"]
        self.extensions = attributes["extensions"] if attributes["extensions"]
      end

      # Converts the Context object into a hash suitable for inclusion in an xAPI Statement.
      #
      # @example
      #   context = ActiveLrs::Xapi::Context.new(
      #     "registration" => "550e8400-e29b-41d4-a716-446655440000",
      #     "instructor" => { "mbox" => "mailto:teacher@example.com" },
      #     "statement" => { "objectType" => "StatementRef", "id" => "8f87ccde-bb56-4c2e-ab83-44982ef22df0" }
      #   )
      #   context.to_h
      #   # => {
      #   #   "registration" => "550e8400-e29b-41d4-a716-446655440000",
      #   #   "instructor" => { "objectType" => "Agent", "mbox" => "mailto:teacher@example.com" },
      #   #   "statement" => { "objectType" => "StatementRef", "id" => "8f87ccde-..." }
      #   # }
      #
      # @return [Hash{String => Object}] a hash including only the present context attributes
      def to_h
        node = {}
        node["registration"] = registration if registration
        node["instructor"] = instructor.to_h if instructor
        node["team"] = team.to_h if team
        node["contextActivities"] = context_activities.to_h if context_activities
        node["revision"] = revision if revision
        node["platform"] = platform if platform
        node["language"] = language if language
        node["statement"] = statement.to_h if statement
        node["extensions"] = extensions if extensions
        node
      end
    end
  end
end
