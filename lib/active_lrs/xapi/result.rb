# frozen_string_literal: true

require "duration"

module ActiveLrs
  module Xapi
    # Represents an xAPI Result object.
    #
    # The Result object captures the outcome of an Activity. It may include
    # scoring, completion status, success, learner response, duration, and
    # additional extensions.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#result
    #   Section 4.2.2.4 "Result"
    class Result
      # @return [Score, nil] The score achieved for the Activity (optional).
      attr_accessor :score

      # @return [Boolean, nil] True if the Activity was successfully completed (optional).
      attr_accessor :success

      # @return [Boolean, nil] True if the Activity was completed (optional).
      attr_accessor :completion

      # @return [String, nil] Learner’s response, e.g., entered text or choice (optional).
      attr_accessor :response

      # @return [String, nil] ISO 8601 duration string representing the time spent (optional).
      attr_accessor :duration

      # @return [Hash{String => Object}, nil] Additional metadata not covered by standard properties.
      attr_accessor :extensions

      # Initializes a new Result instance.
      #
      # @param attributes [Hash] Hash of attributes for the Result object.
      # @option attributes [Hash] "score" A hash representing a Score object.
      # @option attributes [Boolean] "success" Indicates whether the Activity was successful.
      # @option attributes [Boolean] "completion" Indicates whether the Activity was completed.
      # @option attributes [String] "response" Learner's response.
      # @option attributes [String] "duration" Duration in ISO 8601 format.
      # @option attributes [Hash] "extensions" Optional key/value extensions.
      #
      # @return [void]
      def initialize(attributes = {})
        self.score = Xapi::Score.new(attributes["score"]) if attributes["score"]
        self.success = attributes["success"] unless attributes["success"].nil?
        self.completion = attributes["completion"] unless attributes["completion"].nil?
        self.duration = attributes["duration"] if attributes["duration"]
        self.response = attributes["response"] if attributes["response"]
        self.extensions = attributes["extensions"] if attributes["extensions"]
      end

      # Converts the Result object into a hash suitable for inclusion in an xAPI Statement.
      #
      # @example
      #   result = ActiveLrs::Xapi::Result.new(
      #     "score" => { "scaled" => 0.8, "raw" => 80 },
      #     "success" => true,
      #     "completion" => true,
      #     "response" => "42",
      #     "duration" => "PT1H30M",
      #     "extensions" => { "http://example.com/extension" => "value" }
      #   )
      #   result.to_h
      #   # => {
      #   #   "score" => { "scaled" => 0.8, "raw" => 80 },
      #   #   "success" => true,
      #   #   "completion" => true,
      #   #   "response" => "42",
      #   #   "duration" => "PT1H30M",
      #   #   "extensions" => { "http://example.com/extension" => "value" }
      #   # }
      #
      # @return [Hash{String => Object}] A hash representation of the Result object.
      def to_h
        node = {}
        node["score"] = score.to_h if score
        node["success"] = success unless success.nil?
        node["completion"] = completion unless completion.nil?
        node["response"] = response if response
        node["duration"] = format_duration(duration) if duration
        node["extensions"] = extensions if extensions
        node
      end

      private

      def format_duration(value)
        return nil unless value

        case value
        when String
          value # already ISO 8601
        when Numeric
          Duration.new(seconds: value).iso8601
        when Duration
          value.iso8601
        else
          raise ArgumentError, "Unsupported duration type: #{value.class}"
        end
      end
    end
  end
end
