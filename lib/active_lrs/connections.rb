class ActiveLrs::Connections
  # Path to the remote LRS configuration file.
  CONFIG_PATH = File.join(Dir.pwd, "config", "remote_lrs.yml")

  def initialize
    load_connections_from_file(CONFIG_PATH)
    @connections ||= []
  end

  # Retrieve all current connections
  #
  # @return [Array<ActiveLrs::Connection>] Array of ActiveLrs::Connection objects
  def all
    @connections
  end

  # Update the current connections
  #
  # @param connections [Array<ActiveLrs::Connection>] The new connections that will be used
  # @return [Array<ActiveLrs::Connection>] Array of ActiveLrs::Connection objects
  def set(connections)
    @connections = connections
  end

  # Clear all current connections
  #
  # @return [Array] An empty array
  def clear
    set([])
  end

  # Temporarily execute code while using a specific array of connections.
  # After execution, the connections will be reverted to the prior state.
  #
  # @param connections [Array<ActiveLrs::Connection>] The connections to be used in the block
  # @return [Array<ActiveLrs::Connection>] Array of ActiveLrs::Connection objects
  def use(connections)
    previous_connections = all

    set(connections)
    yield
    set(previous_connections)
  end

  # Loads and sets LRS connections from a given file. If the file is missing,
  # no action will be taken.
  #
  # @param path [String] The path to the file
  # @return [void]
  def load_connections_from_file(path)
    if File.exist?(path)
      raw = ERB.new(File.read(path)).result
      yaml = YAML.safe_load(raw, aliases: true)
      env_config = yaml.fetch(ENV["RAILS_ENV"], {})
      connections = env_config["endpoints"] || []
      @connections = connections.map { |conn| ActiveLrs::Connection.parse(conn) }
    end
  end
end
