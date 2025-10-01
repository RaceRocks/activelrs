# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI Verb object.
    #
    # A Verb describes the action that the Actor performed on the Object.
    # Each Verb must have an `id` (IRI) and may optionally include a human-readable
    # `display` map of language codes to strings.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4222-verb
    class Verb
      # @return [String] IRI that uniquely identifies the verb
      attr_accessor :id

      # @return [Hash{String => String}, nil] Optional map of language codes to human-readable representations
      attr_accessor :display

      # @return [String, nil] Optional human-readable verb string for a chosen locale (defaults to first available)
      attr_accessor :name

      # Initializes a new Verb object.
      #
      # @param attributes [Hash] Attributes for the Verb
      # @option attributes [String] "id" Required IRI of the verb
      # @option attributes [Hash{String => String}] "display" Optional human-readable display map
      #
      # @return [void]
      def initialize(attributes = {})
        self.id = attributes["id"] if attributes["id"]

        if attributes["display"]
          self.display = attributes["display"]
          locale = ActiveLrs.configuration.default_locale
          self.name = attributes["display"][locale] || attributes["display"].values.first
        end
      end

      # Converts the Verb object into a hash suitable for xAPI Statements.
      #
      # @example
      #   verb = ActiveLrs::Xapi::Verb.new(
      #     "id" => "http://adlnet.gov/expapi/verbs/completed",
      #     "display" => { "en-US" => "completed" }
      #   )
      #   verb.to_h
      #   # => {
      #   #   "id" => "http://adlnet.gov/expapi/verbs/completed",
      #   #   "display" => { "en-US" => "completed" }
      #   # }
      #
      # @return [Hash{String => Object}] Hash representation of the Verb
      def to_h
        node = {}
        node["id"] = id.to_s if id
        node["display"] = display if display
        node
      end
    end
  end
end
