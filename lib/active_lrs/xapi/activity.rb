# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI Activity object.
    #
    # An Activity is a type of xAPI Object that describes a learning
    # activity, resource, or experience. It must have an `id` and an
    # `objectType` of `"Activity"`. Optionally, it may also include a
    # `definition` that provides human-readable metadata such as name,
    # description, type, or extensions.
    #
    # This class is intended for use as the `object` property within
    # an xAPI Statement.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4223-object
    #   Section 4.2.2.3 "Object" — see the "Object As Activity" subsection
    class Activity
      # @return [String, nil] An IRI (Internationalized Resource Identifier) that
      # uniquely identifies the Activity.
      attr_accessor :id

      # @return [String] The object type. MUST be the literal string "Activity"
      # when present, according to the xAPI specification.
      attr_accessor :object_type

      # @return [ActivityDefinition, nil] Optional metadata about the Activity,
      # including human-readable name, description, type, and extensions.
      attr_accessor :definition

      # Initializes a new Activity instance with optional attributes.
      #
      # @param attributes [Hash] a hash of activity attributes
      # @option attributes [String] "id" An IRI (Internationalized Resource Identifier)
      #   that uniquely identifies the Activity.
      # @option attributes [String] "object_type" The object type. MUST be the literal
      #   string "Activity" when present.
      # @option attributes [ActivityDefinition] "definition" Optional metadata about the
      #   Activity, including name, description, type, and extensions.
      #
      # @return [void]
      def initialize(attributes = {})
        @object_type = "Activity"
        self.id = attributes["id"] if attributes["id"]
        self.definition = ActivityDefinition.new(attributes["definition"]) if attributes["definition"]
      end

      # Converts the Activity object into a hash representation suitable
      # for serialization in an xAPI Statement.
      #
      # @example
      #   activity = ActiveLrs::Xapi::Activity.new(
      #     "id" => "http://example.com/activities/lesson1",
      #     "object_type" => "Activity",
      #     "definition" => definition_object
      #   )
      #   activity.to_h
      #   # => {
      #   #   "id" => "http://example.com/activities/lesson1",
      #   #   "objectType" => "Activity",
      #   #   "definition" => { ... }
      #   # }
      #
      # @return [Hash{String => Object}] a hash including only the present attributes
      #   (`id`, `objectType`, `definition`) suitable for xAPI serialization
      def to_h
        node = {}
        node["objectType"] = object_type
        node["id"] = id.to_s if id
        node["definition"] = definition.to_h if definition
        node
      end
    end
  end
end
