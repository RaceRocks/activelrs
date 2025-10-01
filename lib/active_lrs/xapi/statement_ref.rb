# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI StatementRef object.
    #
    # A StatementRef allows one Statement to refer to another Statement
    # by its `id`. This is useful for embedding or linking statements without
    # duplicating all data. Typically used in the `object` property of a Statement.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4223-object
    #   Section 4.2.2.3 "Object" - see the "Object As Statement" subsection
    class StatementRef
      # @return [String] The object type. MUST be the literal string `"StatementRef"`.
      attr_accessor :object_type

      # @return [String] The ID of the referenced statement.
      attr_accessor :id

      # Initializes a new StatementRef.
      #
      # @param attributes [Hash] Attributes hash containing `id`.
      # @option attributes [String] "id" The ID of the statement to reference (required).
      #
      # @return [void]
      def initialize(attributes = {})
        @object_type = "StatementRef"
        self.id = attributes["id"] if attributes["id"]
      end

      # Converts the StatementRef into a hash suitable for use as the `object` of a Statement.
      #
      # @example
      #   ref = ActiveLrs::Xapi::StatementRef.new("id" => "123e4567-e89b-12d3-a456-426614174000")
      #   ref.to_h
      #   # => { "objectType" => "StatementRef", "id" => "123e4567-e89b-12d3-a456-426614174000" }
      #
      # @return [Hash{String => String}] A hash with `objectType` and `id`.
      def to_h
        node = {}
        node["id"] = id if id
        node["objectType"] = object_type
        node
      end
    end
  end
end
