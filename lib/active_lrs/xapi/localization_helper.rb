# frozen_string_literal: true

module ActiveLrs
  module Xapi
    # Helper methods for resolving localized strings from xAPI statements.
    #
    # Provides functionality to select the most appropriate value from
    # a language map, following xAPI spec conventions and fallbacks.
    module LocalizationHelper
      # Resolve the most appropriate localized string from a language map (per xAPI spec),
      # following a series of fallbacks.
      #
      # The resolution order is:
      #   1. Exact match for the given locale (e.g., "en-US")
      #   2. Variant match of the requested locale (e.g., "en" → "en-US", "en-CA")
      #   3. Exact match for the system default locale (ActiveLrs.configuration.default_locale)
      #   4. Variant match for the system default locale (e.g., "fr" → "fr-CA")
      #   5. First available value in the map
      #
      # If no match is found, returns the string `"undefined"`.
      #
      # @param lang_map [Hash] The language map from an xAPI statement (e.g. `{ "en-US" => "Terminated" }`)
      # @param locale [String, Symbol, nil] The preferred locale (defaults to ActiveLrs.configuration.default_locale
      #   or I18n.locale if available)
      # @return [String] The resolved localized value, or `"undefined"` if no valid entry exists.
      # @example
      #   lang_map = { "en-US" => "Hello", "fr-CA" => "Bonjour" }
      #   get_localized_value(lang_map, "en")    # => "Hello"
      #   get_localized_value(lang_map, "fr")    # => "Bonjour"
      #   get_localized_value(lang_map, "es")    # => "Hello" (fallback)
      #   get_localized_value({}, "en")          # => "undefined"
      def get_localized_value(lang_map, locale = nil)
        return "undefined" unless lang_map.is_a?(Hash) && lang_map.any?

        # Determine locale in safe order
        locale ||= ActiveLrs.configuration.default_locale || (defined?(I18n) && I18n.locale)
        locale = locale.to_s

        # Exact match
        return lang_map[locale] if lang_map.key?(locale)

        # Match variant for requested locale (e.g., "en" → "en-US")
        variant_value = find_variant(lang_map, locale)
        return variant_value if variant_value

        # Fallback to system default locale
        default_locale = ActiveLrs.configuration.default_locale.to_s
        if default_locale != locale
          return lang_map[default_locale] if lang_map.key?(default_locale)

          # Match variant for default locale (e.g., "fr" → "fr-CA")
          variant_value = find_variant(lang_map, default_locale)
          return variant_value if variant_value
        end

        # Fallback to first available value
        lang_map.values.first || "undefined"
      end

      private

      # Finds a variant of a given locale in the language map with prioritized search.
      #
      # The search order is:
      #   1. The base language code itself (e.g., "en", "fr")
      #   2. Common regional fallbacks for the base language
      #      - English ("en"): "en-CA", "en-US", "en-GB"
      #      - French ("fr"): "fr-CA", "fr-FR"
      #   3. Any other variant starting with the base language code (e.g., "en-*", "fr-*")
      #
      # Note: Exact match for the requested locale should be checked before calling this method.
      #       The system default locale is handled separately in get_localized_value.
      #
      # @param lang_map [Hash] the language map from an xAPI statement (e.g., {"en-US" => "Hello"})
      # @param locale [String] the base or region-specific locale to search for
      # @return [String, nil] the best matching value, or nil if no match is found
      # @example
      #   lang_map = { "en-US" => "Hello", "en-CA" => "Hi there", "fr-FR" => "Bonjour", "fr-CA" => "Salut" }
      #   find_variant(lang_map, "en")     # => "en" match if present, else "en-CA"/"en-US"/"en-GB"
      #   find_variant(lang_map, "fr")     # => "fr" match if present, else "fr-CA"/"fr-FR"
      #   find_variant(lang_map, "es")     # => nil
      def find_variant(lang_map, locale)
        base = locale.split("-").first

        # Base language itself
        return lang_map[base] if lang_map.key?(base)

        # Common regional fallbacks
        common_variants = case base
        when "en" then [ "en-CA", "en-US", "en-GB" ]
        when "fr" then [ "fr-CA", "fr-FR" ]
        else []
        end

        common_variants.each do |v|
          return lang_map[v] if lang_map.key?(v)
        end

        # Any other variant starting with base-
        variant = lang_map.find { |k, _v| k.start_with?("#{base}-") }
        return variant[1] if variant

        # Nothing found
        nil
      end
    end
  end
end
