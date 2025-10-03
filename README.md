# ActiveLRS

ActiveLRS is a lightweight Rails gem for working with [xAPI (Experience API)](https://experienceapi.com) data stored in a Learning Record Store (LRS).  

It can generate plain Rails model classes (independent of ActiveRecord) and matching RSpec test files directly from an **xAPI profile**. An xAPI profile defines the vocabulary and structure for specific learning or activity events.  

With ActiveLRS, you can:  
- Generate Rails model classes from an xAPI profile.  
- Automatically create test files for those classes.  
- Fetch and process xAPI statements that match the events defined in your profile.  

This makes it easier to prototype, test, and integrate xAPI-based learning data into your Ruby on Rails applications.

## Installation

1. Add `active_lrs` to your Rails application's `Gemfile`
    ```ruby
    gem "active_lrs", git: "https://github.com/RaceRocks/activelrs"
    ```
    (Default behavior will use the main branch for building the gem, you can specify the branch you want by appending `branch: 'branch-name'` to the line above.)

2. Then from your project directory, run:
    ```bash
    bundle install
    ```

3. Next, you need to run the generator:
    ```bash
    rails generate active_lrs:install
    ```

4. Open `config/remote_lrs.yml` and enter the connection details for your Learning Record Store (LRS). 

    An LRS is a system that stores learning activity data (xAPI statements). If you don’t have an LRS yet, you can use the ADL xAPI Sandbox, which is a free public LRS for testing:  

    - **Endpoint:** `https://lrs.adlnet.gov/xapi/`  
    - **Username / Password:** Sign up for a free account on the ADL website.  

    This allows you to start experimenting with ActiveLRS immediately without setting up your own LRS.

## Configuration

You can configure `ActiveLRS` in a Rails initializer to customize settings for your app:

```ruby
# config/initializers/active_lrs.rb
ActiveLrs.configure do |config|
  # Set the default locale for xAPI statements
  config.default_locale = "fr-FR"

  # Set the URL of your xAPI Profile server
  config.xapi_profile_server_url = "https://my-profiles.example.com/"
end
```

Defaults are used if not overridden:
```ruby
ActiveLrs.configuration.default_locale        # => "en-US"
ActiveLrs.configuration.xapi_profile_server_url # => "https://profiles.adlnet.gov/"
```

## Generators
```bash
rails generate active_lrs:statement <xAPI_Profile_IRI>
```

This generator will fetch an xAPI profile from the [xAPI profile server API](https://profiles.adlnet.gov/api-info/get/by-iri), and create a model within your application (`/app/models/<profile_name>_statement.rb`). Generated models contain helpers to make querying statements easier.

> [!TIP]
> You can find xAPI profiles and their IRIs [here](https://profiles.adlnet.gov/profiles).

## Documentation

For a full list of available functionality, usage details, and examples, please check out the [documentation](https://racerocks.github.io/activelrs).  
This is the best place to explore all classes, modules, and methods provided by the library.

## Development

### 1. Clone the repository
```bash
git clone https://github.com/RaceRocks/activelrs
```  

### 2. Install Dependencies and Build Gem
Navigate to gem directory
```bash
cd active_lrs
```

Install dependencies
```bash
bundle install
```

Build gem
```bash
gem build active_lrs.gemspec
```

## Testing and Quality Assurance

### Testing - RSpec
```shell
# Run entire RSpec test suite:
bundle exec rspec

# Run specific RSpec test files: 
bundle exec rspec spec/path/to/file.rb
```

### Quality Assurance - Rubocop

```shell
# To check entire codebase for violations:
bundle exec rubocop

# To check specific files:  
bundle exec rubocop path/to/file.rb 

# Use the -A flag to auto-correct violations:
bundle exec rubocop -A
```

## Attribution

This project includes code derived from [Xapi](https://github.com/Deakin-Prime/Xapi), 
licensed under MIT. We have modified it for our use case.

## License

The MIT License (MIT).  

© 2025 RaceRocks 3D. See [LICENSE](LICENSE.txt) for details.
