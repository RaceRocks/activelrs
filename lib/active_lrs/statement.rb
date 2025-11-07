require "time"
require "json"

module ActiveLrs
  # Provides an interface to fetch, filter, and manipulate xAPI statements.
  #
  # This class supports fetching statements from configured LRS endpoints,
  # applying `where` conditions, ordering, limiting, and iteration via Enumerable.
  #
  # @example Fetch all statements
  #   statements = ActiveLrs::Statement.all.to_a
  #
  # @example Fetch statements for a specific verb
  #   statements = ActiveLrs::Statement.where(verb: :completed).to_a
  #
  # @example Chain filtering, sorting, and limiting
  #   statements = ActiveLrs::Statement
  #                  .where(verb: :completed)
  #                  .since(Time.now - 7*24*60*60)
  #                  .order(timestamp: :desc)
  #                  .limit(10)
  #                  .to_a
  class Statement
    include Enumerable

    # @!group Class Methods

    # Returns cached statement data or fetches if not loaded.
    #
    # @return [Array<ActiveLrs::Xapi::Statement>] List of fetched statements
    def self.data
      @data ||= self.fetch
    end

    # Sets cached statement data.
    #
    # @param new_data [Array<ActiveLrs::Xapi::Statement>] New statement data
    def self.data=(new_data)
      @data = new_data
    end

    # Returns the configured remote LRS endpoints.
    #
    # @return [Array<Hash>] Array of endpoint hashes from configuration
    def self.remote_lrs_instances
      ActiveLrs.configuration.remote_lrs_instances
    end

    # Fetches statements from all configured LRS endpoints.
    #
    # @return [Array<ActiveLrs::Xapi::Statement>] Array of statements
    # @raise [ActiveLrs::HttpError] If fetching fails for any LRS
    def self.fetch
      statements = []

      self.remote_lrs_instances.each do |lrs|
        client = ActiveLrs::Client.new(
          url: lrs["url"],
          username: lrs["username"],
          password: lrs["password"],
          more_attribute: lrs["more_attribute"] || "more",
          version: lrs["version"] || "2.0.0"
        )

        statements.concat(self::VERBS.values.flat_map do |iri|
          client.fetch_statements(verb: iri)
        end.compact.map { |statement| ActiveLrs::Xapi::Statement.new(statement) }).uniq!(&:id)
      end

      statements
    end

    # Refreshes the cached statement data.
    #
    # @return [Array<ActiveLrs::Xapi::Statement>] Refetched statements
    def self.refresh_data
      @data = self.fetch
    end

    # Returns a new Statement instance for querying.
    #
    # @return [ActiveLrs::Statement]
    def self.all
      new
    end

    # Shortcut for `where` on a new instance.
    #
    # @param conditions [Hash] Filtering conditions
    # @return [ActiveLrs::Statement]
    def self.where(conditions = {})
      new.where(conditions)
    end

    # Shortcut for `since` on a new instance.
    #
    # @param timestamp [Time, String] ISO8601 timestamp or Time object
    # @return [ActiveLrs::Statement]
    def self.since(timestamp)
      new.since(timestamp)
    end

    # Shortcut for `order` on a new instance.
    #
    # @param key_hash [Hash] Key and direction (e.g., { timestamp: :desc })
    # @return [ActiveLrs::Statement]
    def self.order(key_hash)
      new.order(key_hash)
    end

    # Shortcut for `limit` on a new instance.
    #
    # @param num [Integer] Maximum number of statements to return
    # @return [ActiveLrs::Statement]
    def self.limit(num)
      new.limit(num)
    end

    # Shortcut for 'count' on a new instance.
    #
    # @param conditions [Hash] Filtering conditions
    # @return [Integer]
    def self.count(conditions = {})
      if conditions.empty?
        new.count
      else
        new.where(conditions).count
      end
    end

    # Shortcut for 'group' on a new instance.
    #
    # @param field [String] Field to group by
    # @return [ActiveLrs::Statement]
    def self.group(field)
      new.group(field)
    end

    # Shortcut for 'average' on a new instance.
    #
    # @param field [String] Field to calculate average on
    # @return [ActiveLrs::Statement]
    def self.average(field)
      new.average(field)
    end

    # @!endgroup

    # Initializes a new query object.
    #
    # @return [void]
    def initialize
      @where_conditions = []
      @since_timestamp = nil
      @sort_key = nil
      @sort_direction = nil
      @limit = nil
      @group_by = nil
    end

    # Adds filtering conditions.
    #
    # @param conditions [Hash] Conditions to apply (e.g., { verb: :completed })
    # @return [ActiveLrs::Statement] self
    def where(conditions = {})
      @where_conditions << conditions
      self
    end

    # Filters statements since the given timestamp.
    #
    # @param timestamp [Time, String] Time or ISO8601 string
    # @return [ActiveLrs::Statement] self
    def since(timestamp)
      timestamp = timestamp.is_a?(Time) ? timestamp : convert_iso8601_string_to_time(timestamp)
      @where_conditions << { timestamp: timestamp }
      self
    end

    # Orders statements by a key and direction.
    #
    # @param key_hash [Hash] Key and direction (e.g., { timestamp: :desc })
    # @return [ActiveLrs::Statement] self
    def order(key_hash)
      @sort_key, @sort_direction = key_hash.first
      self
    end

    # Limits the number of returned statements.
    #
    # @param num [Integer] Maximum number of statements
    # @return [ActiveLrs::Statement] self
    def limit(num)
      @limit = num
      self
    end

    # Counts statements, optionally applying additional conditions.
    #
    # @param conditions [Hash] Additional filtering conditions (optional)
    # @return [Integer, Hash] Returns an integer if no grouping is applied, or a hash if grouped
    def count(conditions = {})
      return where(conditions).count unless conditions.empty?

      results = to_a
      return results.size unless @group_by

      apply_group_count(results)
    end

    # Calculate the average value of the specified field from statements.
    #
    # @param field [String] Field to calculate average on
    # @return [ActiveLrs::Statement] self
    def average(field)
      statements = to_a
      @group_by ? apply_group_average(statements, field) : apply_average(statements, field)
    end

    # Groups statements by a specified field.
    #
    # @param field [String] Field to group by
    # @return [ActiveLrs::Statement] self
    def group(field)
      @group_by = field
      self
    end

    # Iterates over the filtered statements.
    #
    # @yield [statement] Gives each statement to the block
    # @return [Enumerator] if no block is given
    def each(&block)
      to_a.each(&block)
    end

    # Returns the filtered, ordered, and limited statements as an array.
    #
    # @return [Array<ActiveLrs::Xapi::Statement>] Array of statements
    def to_a
      results = self.class.data

      # Apply where conditions on data
      results = apply_where_conditions(results) unless @where_conditions.empty?

      if @group_by.nil?
        # Apply sorting
        results = apply_sort(results) unless @sort_key.nil?

        # Apply limit
        results = apply_limit(results) unless @limit.nil?
      end

      results
    end

    private

    # Helper to dig into nested attributes using method chains.
    #
    # @param object [Object] The object to dig into
    # @param path [String, Symbol] Dot-separated method path
    # @return [Object, nil] The nested value
    def dig_via_methods(object, path)
      path.to_s.split(".").reduce(object) do |current_object, method|
        begin
          current_object&.public_send(method)
        rescue NoMethodError
          return nil
        end
      end
    end

    # Resolves a verb symbol to a string IRI.
    #
    # Override this in xAPI profile-specific subclasses.
    #
    # @param verb [Symbol, String] Verb symbol or string
    # @return [String] Verb IRI or unchanged string
    def resolve_verb_symbol_to_string_iri(verb)
      verb
    end

    # Converts an ISO8601 string to Time.
    #
    # @param iso_string [String, nil] ISO8601 formatted string
    # @return [Time, nil] Parsed Time or nil if invalid
    def convert_iso8601_string_to_time(iso_string)
      return nil if iso_string.nil?

      Time.iso8601(iso_string)
    rescue ArgumentError
      nil
    end

    # @!group Helpers for filtering, sorting, grouping, and limiting results

    # Filters an array of results based on @where_conditions.
    #
    # @param results [Array] the array of statements to filter
    # @return [Array] the filtered results
    def apply_where_conditions(results)
      results.select do |result|
        @where_conditions.all? do |conditions|
          conditions.all? { |key, value| match_condition?(result, key, value) }
        end
      end
    end

    # Checks if a single result matches a specific key-value condition.
    #
    # @param result [Object] the statement to check
    # @param key [Symbol] the key to check in the result
    # @param value [Object] the value to match against
    # @return [Boolean] true if the result matches the condition, false otherwise
    def match_condition?(result, key, value)
      statement_value = dig_via_methods(result, key)

      value = resolve_value(key, value)

      case key
      when :timestamp
        value.is_a?(Time) ? statement_value >= value : statement_value == value
      else
        statement_value == value
      end
    end

    # Resolves a value for comparison, converting symbols to IRIs if needed.
    #
    # @param key [Symbol] the key being checked
    # @param value [Object] the value to resolve
    # @return [Object] the resolved value
    def resolve_value(key, value)
      value.is_a?(Symbol) ? resolve_verb_symbol_to_string_iri(value) : value
    end

    # Sorts an array of results by a given key or a custom value extractor.
    #
    # @param results [Array] the array of records/statements to sort
    # @param value_extractor [Proc, Symbol, nil] optional custom extractor for sorting
    # @return [Array] the sorted array
    def apply_sort(results, value_extractor: nil)
      sorted = if value_extractor
          results.sort_by(&value_extractor)
      else
          results.sort_by { |result| dig_via_methods(result, @sort_key) }
      end
      @sort_direction == :desc ? sorted.reverse : sorted
    end

    # Limits the number of results returned.
    #
    # @param results [Array] the array of records/statements to limit
    # @return [Array] the limited array
    def apply_limit(results)
      results.first(@limit)
    end

    # Applies a count aggregation to grouped statements.
    #
    # @param statements [Array<ActiveLrs::Xapi::Statement>] the array of xAPI statements to group and count
    # @return [Hash] a hash of groups with their counts
    def apply_group_count(statements)
      apply_aggregate(statements) { |group_statements| group_statements.size }
    end

    # Applies an average aggregation to grouped statements for a given field.
    #
    # @param statements [Array<ActiveLrs::Xapi::Statement>] the array of xAPI statements to group and calculate average on
    # @param field [Symbol] the field to calculate the average on
    # @return [Hash] a hash of groups with their average values
    def apply_group_average(statements, field)
      apply_aggregate(statements) { |group_statements| apply_average(group_statements, field) }
    end

    # Aggregates grouped statements using a block to define the aggregation.
    #
    # @param statements [Array<ActiveLrs::Xapi::Statement>] the array of xAPI statements to group and aggregate on
    # @yield [Array] yields each group of statements to the block
    # @return [Hash] a hash of groups with aggregated values
    def apply_aggregate(statements)
      grouped_results = apply_group(statements)

      results = grouped_results.transform_values do |group_statements|
        yield(group_statements)
      end

      # Sort counts by ascending as default
      results = apply_sort(results, value_extractor: :last) unless @sort_key.nil?

      results = apply_limit(results) unless @limit.nil?

      results.to_h
    end

    # Computes the average value for a given field in an array of xAPI statements.
    #
    # @param statements [Array<ActiveLrs::Xapi::Statement>] the array of xAPI statements
    # @param field [Symbol] the field to calculate the average on
    # @return [Float, nil] the average value or nil if no valid values
    def apply_average(statements, field)
      total = 0.0

      statements.each do |statement|
        value = dig_via_methods(statement, field)
        total += value unless value.nil?
      end

      count = statements.count

      count != 0 ? (total / count) : nil
    end

    # Groups an array of xAPI statements by the @group_by key.
    #
    # @param statements [Array<ActiveLrs::Xapi::Statement>] the array of xAPI statements to group
    # @return [Hash] a hash with group keys mapping to arrays of statements
    def apply_group(statements)
      results = Hash.new { |h, k| h[k] = [] }

      statements.each do |statement|
        key = dig_via_methods(statement, @group_by)
        results[key] << statement
      end

      results
    end

    # @!endgroup
  end
end
