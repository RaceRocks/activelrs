require "rails/generators"
require "faraday"

# Rails generator to fetch an xAPI profile and generate a statement model.
#
# This generator connects to the xAPI Profile Server, fetches the profile
# document for the given IRI, extracts verbs, and generates a Rails model
# representing xAPI statements for that profile.
#
# @example Generate a statement model for a profile
#   rails generate active_lrs:statement "http://example.com/xapi/profile/1234"
class ActiveLrs::StatementGenerator < Rails::Generators::Base
  # Directory containing generator templates
  source_root File.expand_path("templates", __dir__)

  # xAPI profile IRI to fetch
  #
  # @return [String]
  argument :xapi_profile_iri, type: :string, required: true

  # Fetches the xAPI profile document from the configured profile server.
  #
  # @return [void]
  # @raise [SystemExit] Exits with status 1 if the fetch fails
  def fetch_xapi_profile_document
    connection = Faraday.new(url: ActiveLrs.configuration.xapi_profile_server_url) do |builder|
      builder.response :json
    end

    response = connection.get("api/profile", iri: xapi_profile_iri)

    unless response.success?
      say_status :error, "Unable to fetch xAPI profile.", :red
      exit 1
    end

    @xapi_profile_document = response.body
  end

  # Parses verbs defined in the "concepts" section of the xAPI profile.
  #
  # @return [void]
  def parse_concepts_verbs
    @verbs = @xapi_profile_document.dig("concepts").filter_map do |concept|
      {
        name: concept.dig("prefLabel", "en"),
        iri: concept.dig("id")
      } if concept.dig("type") == "Verb"
    end
  end

  # Parses verbs defined in the "templates" section of the xAPI profile
  # and adds them if they are not already present.
  #
  # @return [void]
  def parse_templates_verbs
    @verbs += @xapi_profile_document.dig("templates").filter_map do |template|
      iri = template.dig("verb")
      {
        name: template.dig("prefLabel", "en"),
        iri: iri
      } if template.key?("verb") && @verbs.none? { |verb| verb[:iri] == iri }
    end
  end

  # Generates a Rails model file for the xAPI statements of this profile.
  #
  # The model file is generated using the `model.rb.tt` template and
  # named based on the xAPI profile's prefLabel.
  #
  # @return [void]
  def create_model
    @xapi_profile_name = @xapi_profile_document.dig("prefLabel", "en")
    @file_name = "#{@xapi_profile_name.parameterize.underscore}_statement"
    @class_name = @file_name.camelize

    template "model.rb.tt", "app/models/#{@file_name}.rb"
  end
end
