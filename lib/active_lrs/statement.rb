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

      group_count(results)
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
      unless @where_conditions.empty?
        results = results.select do |result|
          @where_conditions.all? do |conditions|
            conditions.all? do |key, value|
              statement_value = dig_via_methods(result, key)

              value = value.is_a?(Symbol) ? resolve_verb_symbol_to_string_iri(value) : value

              if key == :verb
                value = value.is_a?(Symbol) ? resolve_verb_symbol_to_string_iri(value) : value
                statement_value == value
              elsif key == :timestamp && value.is_a?(Time)
                statement_value >= value
              else
                statement_value == value
              end
            end
          end
        end
      end

      # Apply sorting
      unless @sort_key.nil?
        results = results.sort_by do |result|
          value = dig_via_methods(result, @sort_key)
        end
        results.reverse! if @sort_direction == :desc
      end

      # Apply limit
      results = results.first(@limit) if @limit && @group_by.nil?

      results
    end

    private

    # Helper for counting statements grouped by a field.
    #
    # @param statements [Array<ActiveLrs::Xapi::Statement>] Array of xAPI statement objects to count
    # @return [Hash] Hash of grouped counts
    def group_count(statements)
      counts = {}

      statements.each do |statement|
        key = dig_via_methods(statement, @group_by)
        counts[key] ||= 0
        counts[key] += 1
      end

      # Sort counts by ascending as default
      sorted_counts = counts.sort_by(&:last)
      sorted_counts.reverse! if @sort_direction == :desc

      sorted_counts = sorted_counts.first(@limit) if @limit
      sorted_counts.to_h
    end

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
  end
end
