# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI ActivityDefinition object.
    #
    # ActivityDefinition provides metadata for an Activity. It describes the
    # nature, type, and content of the activity, including human-readable
    # labels, interaction type, scoring, and other extensions.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4223-object
    #   Section 4.2.2.3 "Object" — see the "Activity Definition" subsection
    class ActivityDefinition
      include LocalizationHelper

      # @return [Hash{String => String}, nil] Language map for the activity's name.
      attr_accessor :name

      # @return [Hash{String => String}, nil] Language map for the activity's description.
      attr_accessor :description

      # @return [String, nil] The activity type as an IRI (e.g., http://adlnet.gov/expapi/activities/course)
      attr_accessor :type

      # @return [String, nil] An IRI (URL) that resolves to a document providing
      # human-readable information about the Activity. This may include
      # instructions, descriptions, or a way to launch the activity.
      attr_accessor :more_info

      # @return [String, nil] The interaction type for interaction activities
      #   (e.g., 'choice', 'sequencing', 'likert', etc.)
      attr_accessor :interaction_type

      # @return [Array<String>, nil] Correct response patterns for interaction activities.
      attr_accessor :correct_responses_pattern

      # @return [Array<InteractionComponent>, nil] Choices for 'choice' interaction types.
      attr_accessor :choices

      # @return [Array<InteractionComponent>, nil] Scale for 'scale' interaction types.
      attr_accessor :scale

      # @return [Array<InteractionComponent>, nil] Source components for 'matching' interaction types.
      attr_accessor :source

      # @return [Array<InteractionComponent>, nil] Target components for 'matching' interaction types.
      attr_accessor :target

      # @return [Array<InteractionComponent>, nil] Steps for 'sequencing' interaction types.
      attr_accessor :steps

      # @return [Hash{String => Object}, nil] Extensions for additional metadata.
      attr_accessor :extensions

      # Initializes a new ActivityDefinition instance.
      #
      # @param attributes [Hash] A hash of activity definition attributes.
      # @option attributes [Hash{String => String}] "name" Language map for the activity's name.
      # @option attributes [Hash{String => String}] "description" Language map for description.
      # @option attributes [String] "type" IRI of the activity type.
      # @option attributes [String] "moreInfo" Documentation URL of the activity.
      # @option attributes [String] "interactionType" Interaction type string.
      # @option attributes [Array<String>] "correctResponsesPattern" Correct response patterns.
      # @option attributes [Array<Hash>] "choices" Array of InteractionComponent hashes.
      # @option attributes [Array<Hash>] "scale" Array of InteractionComponent hashes.
      # @option attributes [Array<Hash>] "source" Array of InteractionComponent hashes.
      # @option attributes [Array<Hash>] "target" Array of InteractionComponent hashes.
      # @option attributes [Array<Hash>] "steps" Array of InteractionComponent hashes.
      # @option attributes [Hash] "extensions" Key/value pairs for extensions.
      #
      # @return [void]
      def initialize(attributes = {})
        self.name = attributes["name"] if attributes["name"]
        self.description = attributes["description"] if attributes["description"]
        self.type = attributes["type"] if attributes["type"]
        self.more_info = attributes["moreInfo"] if attributes["moreInfo"]
        self.interaction_type = attributes["interactionType"] if attributes["interactionType"]
        self.correct_responses_pattern = attributes["correctResponsesPattern"] if attributes["correctResponsesPattern"]
        self.choices = attributes["choices"]&.map { |choice| InteractionComponent.new(choice) }
        self.scale = attributes["scale"]&.map { |scale| InteractionComponent.new(scale) }
        self.source = attributes["source"]&.map { |source| InteractionComponent.new(source) }
        self.target = attributes["target"]&.map { |target| InteractionComponent.new(target) }
        self.steps = attributes["steps"]&.map { |step| InteractionComponent.new(step) }
        self.extensions = attributes["extensions"] if attributes["extensions"]
      end

      # Converts the ActivityDefinition into a hash suitable for inclusion
      # in an xAPI Activity object.
      #
      # @example
      #   activity_def = ActiveLrs::Xapi::ActivityDefinition.new(
      #     "name" => { "en-US" => "Example Course" },
      #     "description" => { "en-US" => "An introductory example." },
      #     "type" => "http://adlnet.gov/expapi/activities/course",
      #     "interactionType" => "choice",
      #     "correctResponsesPattern" => ["golf", "tennis"],
      #     "choices" => [
      #       { "id" => "golf", "description" => { "en-US" => "Golf" } },
      #       { "id" => "tennis", "description" => { "en-US" => "Tennis" } }
      #     ],
      #     "moreInfo" => "http://example.com/course"
      #   )
      #   activity_def.to_h
      #   # => {
      #   #   "name" => { "en-US" => "Example Course" },
      #   #   "description" => { "en-US" => "An introductory example." },
      #   #   "type" => "http://adlnet.gov/expapi/activities/course",
      #   #   "interactionType" => "choice",
      #   #   "correctResponsesPattern" => ["golf", "tennis"],
      #   #   "choices" => [
      #   #     { "id" => "golf", "description" => { "en-US" => "Golf" } },
      #   #     { "id" => "tennis", "description" => { "en-US" => "Tennis" } }
      #   #   ],
      #   #   "moreInfo" => "http://example.com/course"
      #   # }
      #
      # @return [Hash{String => Object}] A hash including only the present attributes.
      def to_h
        node = {}
        node["name"] = name if name
        node["description"] = description if description
        node["type"] = type.to_s if type
        node["moreInfo"] = more_info.to_s if more_info
        node["extensions"] = extensions if extensions
        if interaction_type
          node["interactionType"] = interaction_type.to_s
          case interaction_type
          when "choice", "sequencing"
            node["choices"] = choices.map { |element| element.to_h } if choices && choices.any?
          when "likert"
            node["scale"] = scale.map { |element| element.to_h } if scale && scale.any?
          when "matching"
            node["source"] = source.map { |element| element.to_h } if source && source.any?
            node["target"] = target.map { |element| element.to_h } if target && target.any?
          when "performance"
            node["steps"] = steps.map { |element| element.to_h } if steps && steps.any?
          end
        end

        if correct_responses_pattern&.any?
          node["correctResponsesPattern"] = correct_responses_pattern.map { |element| element }
        end

        node
      end

      # Returns the localized name of the activity.
      #
      # @param locale [String, Symbol, nil] Optional locale to use. Defaults to nil (will use configured defaults).
      # @return [String] The localized name, or "undefined" if not available.
      def localize_name(locale: nil)
        get_localized_value(name, locale)
      end

      # Returns the localized description of the activity.
      #
      # @param locale [String, Symbol, nil] Optional locale to use. Defaults to nil (will use configured defaults).
      # @return [String] The localized description, or "undefined" if not available.
      def localize_description(locale: nil)
        get_localized_value(description, locale)
      end
    end
  end
end
