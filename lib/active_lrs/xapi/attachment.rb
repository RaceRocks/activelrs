# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Represents an xAPI Attachment object.
    #
    # Attachments provide additional context or supporting data for an xAPI
    # Statement, such as documents, media files, or extensions. Each
    # Attachment includes metadata such as usage type, display name, content
    # type, length, and a SHA-2 hash for validation.
    #
    # This class is intended for use in the `attachments` property of an
    # xAPI Statement.
    #
    # @see https://opensource.ieee.org/xapi/xapi-base-standard-documentation/-/blob/main/9274.1.1%20xAPI%20Base%20Standard%20for%20LRSs.md#4237-attachments
    class Attachment
      # @return [String, nil] An IRI indicating the intended use of this Attachment
      #   (e.g., "http://id.tincanapi.com/attachment/supporting_media").
      attr_accessor :usage_type

      # @return [Hash{String => String}, nil] A language map providing a display
      #   name for the Attachment.
      attr_accessor :display

      # @return [Hash{String => String}, nil] A language map providing a human-readable
      #   description of the Attachment.
      attr_accessor :description

      # @return [String, nil] The MIME type of the Attachment (e.g., "image/png").
      attr_accessor :content_type

      # @return [Integer, nil] The size of the Attachment file in bytes.
      attr_accessor :length

      # @return [String, nil] The SHA-2 hash of the Attachment data, used for integrity checks.
      attr_accessor :sha2

      # @return [String, nil] An IRL (Internationalized Resource Locator) pointing
      #   to the Attachment file.
      attr_accessor :file_url

      # Initializes a new Attachment instance with optional attributes.
      #
      # @param attributes [Hash] a hash of attachment attributes
      # @option attributes [String] "usageType" An IRI describing the use of the attachment.
      # @option attributes [Hash{String => String}] "display" A language map for the display name.
      # @option attributes [Hash{String => String}] "description" A language map for the description.
      # @option attributes [String] "contentType" The MIME type of the attachment.
      # @option attributes [Integer] "length" The size of the attachment in bytes.
      # @option attributes [String] "sha2" The SHA-2 hash of the attachment.
      # @option attributes [String] "fileUrl" An IRL pointing to the attachment.
      #
      # @return [void]
      def initialize(attributes = {})
        self.usage_type = attributes["usageType"] if attributes["usageType"]
        self.display = attributes["display"] if attributes["display"]
        self.description = attributes["description"] if attributes["description"]
        self.content_type = attributes["contentType"] if attributes["contentType"]
        self.length = attributes["length"] if attributes["length"]
        self.sha2 = attributes["sha2"] if attributes["sha2"]
        self.file_url = attributes["fileUrl"] if attributes["fileUrl"]
      end

      # Converts the Attachment object into a hash representation suitable
      # for serialization in an xAPI Statement.
      #
      # @example
      #   attachment = ActiveLrs::Xapi::Attachment.new(
      #     "usageType" => "http://id.tincanapi.com/attachment/supporting_media",
      #     "display" => { "en-US" => "Screenshot" },
      #     "contentType" => "image/png",
      #     "length" => 12345,
      #     "sha2" => "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12",
      #     "fileUrl" => "https://example.com/screenshot.png"
      #   )
      #   attachment.to_h
      #   # => {
      #   #   "usageType" => "http://id.tincanapi.com/attachment/supporting_media",
      #   #   "display" => { "en-US" => "Screenshot" },
      #   #   "contentType" => "image/png",
      #   #   "length" => 12345,
      #   #   "sha2" => "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12",
      #   #   "fileUrl" => "https://example.com/screenshot.png"
      #   # }
      #
      # @return [Hash{String => String, Hash, Integer}] a hash including only
      #   the present attributes
      def to_h
        node = {}
        node["usageType"] = usage_type if usage_type
        node["display"] = display if display
        node["description"] = description if description
        node["contentType"] = content_type if content_type
        node["length"] = length if length
        node["sha2"] = sha2 if sha2
        node["fileUrl"] = file_url if file_url
        node
      end
    end
  end
end
