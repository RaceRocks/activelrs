# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI Interaction Component.
    #
    # Interaction components are used in certain ActivityDefinitions where
    # an interactionType is specified (e.g. multiple choice, sequencing, matching, etc.).
    # They describe the options or elements involved (choices, scale steps, source/target,
    # etc.). Each component must have an `id`, and may include a `description` map.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#interaction-components
    #   Section "Interaction Components" of the "Interaction Activities" Table — describes
    #   required/optional properties of interaction components
    class InteractionComponent
      # @return [String] The identifier for this component (required).
      attr_accessor :id

      # @return [Hash{String => String}, nil] A language map providing a human-readable
      #   description of the component (optional).
      attr_accessor :description

      # Initializes a new InteractionComponent instance with optional attributes.
      #
      # @param attributes [Hash] a hash of attributes for the interaction component
      # @option attributes [String] "id" The identifier for the component (required).
      # @option attributes [Hash{String => String}] "description" A language map for display text.
      #
      # @return [void]
      def initialize(attributes = {})
        self.id = attributes["id"] if attributes["id"]
        self.description = attributes["description"] if attributes["description"]
      end

      # Converts the InteractionComponent into a hash form suitable for
      # inclusion in an ActivityDefinition interactionType component list.
      #
      # @example
      #   component = ActiveLrs::Xapi::InteractionComponent.new(
      #     "id" => "choice_A",
      #     "description" => { "en-US" => "Option A" }
      #   )
      #   component.to_h
      #   # => { "id" => "choice_A", "description" => { "en-US" => "Option A" } }
      #
      # @return [Hash{String => (String, Hash)}] a hash with id and optionally description
      def to_h
        node = {}
        node["id"] = id if id
        node["description"] = description if description
        node
      end
    end
  end
end
