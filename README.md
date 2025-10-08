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
    This will install the most recent version of the gem to your rails app.  
    
    For a specific branch of the gem use 
    ```ruby
    gem "active_lrs", git: "https://github.com/RaceRocks/activelrs" branch: <the branch name>
    ```

2. Save your `Gemfile` and run:
    ```bash
    bundle install
    ```
    or
    ```bash
    bundle update
    ```

3. To install active_lrs, run the rails generator from your rails app directory:
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
##  Racerocks: Standards-Driven Development

This project is actively maintained by the **Racerocks Core Engineering Team**, a specialized group dedicated to building **robust, next-generation training software**.

* **Standards Leadership:** Our team holds a leadership role as a **Technical Editor** on the **TLA Study Group** (IEEE/LTSC), ensuring `activelrs` is developed with a deep, standards-driven understanding of distributed learning.
* **Mission:** **Racerocks** is committed to "Empowering through limitless learning" and is trusted by defense and security leaders to strengthen national readiness through innovation.

* **Learn more:** [https://www.racerocks3d.ca](https://www.racerocks3d.com)


---

## Core Maintainers and Authors

These are the **trusted architects and developers** who collaboratively drive the vision, manage the repository, and ensure the quality and stability of `activelrs`. They represent our unified expertise in modern learning data systems.

| Name | Role / Focus Area | GitHub Profile | Company Title |
| :--- | :--- | :--- | :--- |
| **Amie Walton** | Architect & Standards Lead (TLA/IEEE) | [@AmieAtRR](https://github.com/AmieAtRR) | VP of Technology |
| **Justin Granofsky** | Core Maintainer / Contributor | [@justinGranof](https://github.com/justinGranof) | Full Stack Developer |
| **Ira Susanto** | Core Maintainer / Contributor | [@ira-susanto](https://github.com/ira-susanto) | Full Stack Developer |
| **Sam Foran** | Core Maintainer / Contributor  | [@s-foran](https://github.com/s-foran) | Full Stack Developer |

---


## Community Contributors

We deeply appreciate contributions from the wider open-source community, which help this project grow stronger and more versatile.

* [@amielouwho](https://github.com/amielouwho) | ![Hacktoberfest](https://img.shields.io/badge/-Hacktoberfest%202025-ff69b4) ![Open Source](https://img.shields.io/badge/%20open%20source-green) |

> Outside contributions — code, documentation, bug fixes, ideas — are always welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) for how to get involved.


## Attribution

This project includes code derived from [Xapi](https://github.com/Deakin-Prime/Xapi), 
licensed under MIT. We have modified it for our use case.

## License

The MIT License (MIT).  

© 2025 RaceRocks 3D. See [LICENSE](LICENSE.txt) for details.
