# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI ContextActivities object.
    #
    # ContextActivities provide contextual information about the Activity
    # related to a Statement. They allow grouping, categorization, or
    # relationships to other Activities.
    #
    # Each property is an array of {Activity} objects.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4225-context
    class ContextActivities
      # @return [Array<Activity>, nil] A parent Activity with a more general scope
      #   than the Statement’s object Activity (e.g., "Course" as parent of "Lesson").
      attr_accessor :parent

      # @return [Array<Activity>, nil] Activities used to group Statements for reporting
      #   purposes (e.g., "Unit 1" grouping multiple lessons).
      attr_accessor :grouping

      # @return [Array<Activity>, nil] A categorization tag indicating a profile
      #   or context (e.g., "SCORM profile", "performance review").
      attr_accessor :category

      # @return [Array<Activity>, nil] Any other contextually relevant Activities
      #   not covered by parent, grouping, or category.
      attr_accessor :other

      # Initializes a new ContextActivity instance with optional context activity attributes.
      #
      # @param attributes [Hash] a hash of context activity attributes
      # @option attributes [Array<Hash>] "parent" Array of Activity hashes describing parent context.
      # @option attributes [Array<Hash>] "grouping" Array of Activity hashes describing grouping context.
      # @option attributes [Array<Hash>] "category" Array of Activity hashes describing categorization context.
      # @option attributes [Array<Hash>] "other" Array of Activity hashes describing other context.
      #
      # @return [void]
      def initialize(attributes = {})
        self.parent = Array(attributes["parent"]).map { |element| Activity.new(element) } if attributes["parent"]
        self.grouping = Array(attributes["grouping"]).map { |element| Activity.new(element) } if attributes["grouping"]
        self.other = Array(attributes["other"]).map { |element| Activity.new(element) } if attributes["other"]
        self.category = Array(attributes["category"]).map { |element| Activity.new(element) } if attributes["category"]
      end

      # Converts the ContextActivity into a hash suitable for inclusion in an xAPI Statement.
      #
      # @example
      #   context_activities = ActiveLrs::Xapi::ContextActivity.new(
      #     "parent" => [{ "id" => "http://example.com/course/1" }],
      #     "grouping" => [{ "id" => "http://example.com/unit/1" }]
      #   )
      #   context_activities.to_h
      #   # => {
      #   #   "parent" => [{ "id" => "http://example.com/course/1", "objectType" => "Activity" }],
      #   #   "grouping" => [{ "id" => "http://example.com/unit/1", "objectType" => "Activity" }]
      #   # }
      #
      # @return [Hash{String => Array<Hash>}] a hash including only the present context activities
      def to_h
        node = {}
        node["parent"] = parent.map { |element| element.to_h } if parent && parent.any?
        node["grouping"] = grouping.map { |element| element.to_h } if grouping && grouping.any?
        node["other"] = other.map { |element| element.to_h } if other && other.any?
        node["category"] = category.map { |element| element.to_h } if category && category.any?
        node
      end
    end
  end
end
