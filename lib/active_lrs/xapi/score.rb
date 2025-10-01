# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI Score object, which can include
    # normalized (scaled), raw, minimum, and maximum values.
    #
    # This maps directly to the `score` property inside
    # an xAPI `Result` object.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4224-result
    #   — see the "Score" subsection
    class Score
      # @return [Numeric, nil] the normalized score (0.0–1.0 range, typically)
      attr_accessor :scaled

      # @return [Numeric, nil] the raw score as reported
      attr_accessor :raw

      # @return [Numeric, nil] the minimum possible score
      attr_accessor :min

      # @return [Numeric, nil] the maximum possible score
      attr_accessor :max

      # Initializes a new Score instance with optional attributes.
      #
      # @param attributes [Hash] a hash of score attributes
      # @option attributes [Numeric, String] "scaled" the normalized score (0.0–1.0 range, typically)
      # @option attributes [Numeric, String] "raw" the raw score as reported
      # @option attributes [Numeric, String] "min" the minimum possible score
      # @option attributes [Numeric, String] "max" the maximum possible score
      #
      # @return [void]
      def initialize(attributes = {})
        self.scaled = attributes["scaled"] if attributes["scaled"]
        self.raw = attributes["raw"] if attributes["raw"]
        self.min = attributes["min"] if attributes["min"]
        self.max = attributes["max"] if attributes["max"]
      end

      # Converts the Score object into a hash representation suitable
      # for serialization in an xAPI Statement.
      #
      # @example
      #   score = ActiveLrs::Xapi::Score.new("scaled" => 0.8, "raw" => 80, "min" => 0, "max" => 100)
      #   score.to_h
      #   # => { "scaled" => 0.8, "raw" => 80, "min" => 0, "max" => 100 }
      #
      # @return [Hash{String => Numeric}] a hash including only the present score attributes
      def to_h
        node = {}
        node["scaled"] = scaled if scaled
        node["raw"] = raw if raw
        node["min"] = min if min
        node["max"] = max if max
        node
      end
    end
  end
end
