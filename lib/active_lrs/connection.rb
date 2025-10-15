class ActiveLrs::Connection
  attr_accessor :name, :url, :username, :password, :version, :more_attribute

  def initialize(name:, url:, username:, password:, version:, more_attribute:)
    @name = name
    @url = url
    @username = username
    @password = password
    @version = version || "2.0.0"
    @more_attribute = more_attribute || "more"
  end

  def self.parse(hash_connection)
    new(
      name: hash_connection["name"],
      url: hash_connection["url"],
      username: hash_connection["username"],
      password: hash_connection["password"],
      version: hash_connection["version"],
      more_attribute: hash_connection["more_attribute"]
    )
  end
end
