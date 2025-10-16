class ActiveLrs::Connections
  CONFIG_PATH = File.join(Dir.pwd, "config", "remote_lrs.yml")

  def initialize
    load_connections_from_file(CONFIG_PATH)
    @connections ||= []
  end

  def set(connections)
    @connections = connections
  end

  def all
    @connections
  end

  def clear
    set([])
  end

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
