#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "active_lrs"

# statement_json = '{
#   "id": "84971fda-0077-4e51-8d24-2d14b35f3e80",
#   "verb": {
#     "id": "http://adlnet.gov/expapi/verbs/experienced",
#     "display": {
#       "en-US": "experienced"
#     }
#   },
#   "actor": {
#     "mbox": "mailto:ganes6plus@gmail.com",
#     "name": "GaneshMysore",
#     "objectType": "Agent"
#   },
#   "object": {
#     "id": "http://id.tincanapi.com/activity/tincan-prototypes/launcher",
#     "definition": {
#       "name": {
#         "en-US": "Tin Can Prototypes Launcher"
#       },
#       "type": "http://id.tincanapi.com/activitytype/lms",
#       "description": {
#         "en-US": "A tool for launching the Tin Can prototypes. Simulates the role of an LMS in launching experiences."
#       }
#     },
#     "objectType": "Activity"
#   },
#   "stored": "2025-08-25T13:14:52.051876+00:00",
#   "context": {
#     "registration": "0e294447-20c7-4836-9829-b130f31a4c75",
#     "contextActivities": {
#       "category": [
#         {
#           "id": "http://id.tincanapi.com/recipe/tincan-prototypes/launcher/1",
#           "definition": {
#             "type": "http://id.tincanapi.com/activitytype/recipe"
#           },
#           "objectType": "Activity"
#         },
#         {
#           "id": "http://id.tincanapi.com/activity/tincan-prototypes/launcher-template",
#           "definition": {
#             "name": {
#               "en-US": "Tin Can Launcher Template"
#             },
#             "type": "http://id.tincanapi.com/activitytype/source",
#             "description": {
#               "en-US": "A launch tool based on the Tin Can launch prototypes."
#             }
#           },
#           "objectType": "Activity"
#         }
#       ],
#       "grouping": [
#         {
#           "id": "http://id.tincanapi.com/activity/tincan-prototypes",
#           "objectType": "Activity"
#         }
#       ]
#     }
#   },
#   "version": "1.0.0",
#   "authority": {
#     "mbox": "mailto:ganesh6plus@gmail.com",
#     "name": "GaneshMysore",
#     "objectType": "Agent"
#   },
#   "timestamp": "2025-08-25T13:14:48.611000+00:00"
# }'

begin
  # @todo: replace these placeholders with your actual remote LRS credentials and xAPI statement ID
  client = ActiveLrs::Client.new(url: "<url>", username: "<username>", password: "<password>")
  statement = client.fetch_statement("<xapi_statement_id>")

  statement_hash = JSON.parse(statement)

  stmt = ActiveLrs::Xapi::Statement.new(statement_hash)

  puts "xAPI Statement Object"
  stmt.instance_variables.each do |var|
    value = stmt.instance_variable_get(var)
    puts "#{var}: #{value.inspect}"
  end

  puts "-------------------------"

  puts "xAPI Statement Hash"
  stmt_hash = stmt.to_h
  puts stmt_hash
  puts "Hash Equality Check: #{statement_hash == stmt_hash}"

  statement_hash.each do |k, v|
    if !stmt_hash.key?(k)
      puts "Missing key in stmt_hash: #{k}"
    elsif stmt_hash[k] != v
      puts "Value mismatch for key '#{k}': original=#{v.inspect}, to_h=#{stmt_hash[k].inspect}"
    end
  end

  # Find keys in stmt_hash that are not in statement
  stmt_hash.each_key do |k|
    puts "Extra key in stmt_hash: #{k}" unless statement_hash.key?(k)
  end
rescue ActiveLrs::HttpError => e
  puts "Request failed with status #{e.status}"
  puts "Body: #{e.body}"
rescue ActiveLrs::ParseError
  puts "Failed to parse xAPI statement"
end
