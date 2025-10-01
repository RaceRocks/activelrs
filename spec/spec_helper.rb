# frozen_string_literal: true

require "active_lrs"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_path
  File.expand_path("fixtures", __dir__)
end

def fixture(file)
  File.new(File.join(fixture_path, "/", file))
end

def fixture_contents(file)
  File.read(File.join(fixture_path, file))
end
