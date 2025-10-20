# frozen_string_literal: true

require_relative "lib/active_lrs/version"

Gem::Specification.new do |spec|
  spec.name = "active_lrs"
  spec.version = ActiveLrs::VERSION
  spec.authors = [ "RaceRocks 3D" ]
  spec.email = [ "admin@racerocks3d.com" ]

  spec.summary = "Generate Ruby models and tests from xAPI profiles, and fetch matching data from an LRS."
  spec.description = <<~DESC
    ActiveLRS is a lightweight Rails gem for working with [xAPI (Experience API)](https://experienceapi.com) data stored in a Learning Record Store (LRS).

    It can generate plain Rails model classes (independent of ActiveRecord) and matching RSpec test files directly from an **xAPI profile**. An xAPI profile defines the vocabulary and structure for specific learning or activity events.

    With ActiveLRS, you can:
    - Generate Rails model classes from an xAPI profile.
    - Automatically create test files for those classes.
    - Fetch and process xAPI statements that match the events defined in your profile.

    This makes it easier to prototype, test, and integrate xAPI-based learning data into your Ruby on Rails applications.
  DESC
  spec.homepage = "https://github.com/RaceRocks/activelrs"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://github.com/RaceRocks/activelrs"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RaceRocks/activelrs"
  spec.metadata["changelog_uri"] = "https://github.com/RaceRocks/activelrs/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ doc/ test/ spec/ features/ .yardoc .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "faraday", "~> 2.10"
  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "ruby-duration", "~> 3.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
