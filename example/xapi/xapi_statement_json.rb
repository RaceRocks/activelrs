#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "active_lrs"

statement_json = '{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "actor": {
    "objectType": "Agent",
    "name": "Jane Doe",
    "mbox": "mailto:jane.doe@example.com"
  },
  "verb": {
    "id": "http://adlnet.gov/expapi/verbs/completed",
    "display": { "en-US": "completed" }
  },
  "object": {
    "objectType": "Activity",
    "id": "http://example.com/courses/intro-to-xapi",
    "definition": {
      "name": { "en-US": "Intro to xAPI Course" },
      "description": { "en-US": "An introductory course on the Experience API." },
      "type": "http://adlnet.gov/expapi/activities/course",
      "moreInfo": "http://example.com/courses/intro-to-xapi/details",
      "extensions": {
        "http://example.com/extensions/difficulty": "beginner",
        "http://example.com/extensions/length": "2h"
      }
    }
  },
  "result": {
    "score": {
      "scaled": 0.95,
      "raw": 95,
      "min": 0,
      "max": 100
    },
    "success": true,
    "completion": true,
    "response": "Excellent course!",
    "duration": "PT2H",
    "extensions": {
      "http://example.com/extensions/time-on-task": "PT1H45M"
    }
  },
  "context": {
    "registration": "ec531277-b57b-4c15-8d91-d292c5b2b8f7",
    "instructor": {
      "objectType": "Agent",
      "name": "Dr. Smith",
      "mbox": "mailto:dr.smith@example.com"
    },
    "team": {
      "objectType": "Group",
      "name": "Cohort A",
      "member": [
        { "objectType": "Agent", "mbox": "mailto:student1@example.com" },
        { "objectType": "Agent", "mbox": "mailto:student2@example.com" }
      ]
    },
    "contextActivities": {
      "parent": [
        { "objectType": "Activity", "id": "http://example.com/programs/training" }
      ],
      "grouping": [
        { "objectType": "Activity", "id": "http://example.com/tracks/track1" }
      ],
      "category": [
        { "objectType": "Activity", "id": "https://w3id.org/xapi/scorm" }
      ],
      "other": [
        { "objectType": "Activity", "id": "http://example.com/other/context" }
      ]
    },
    "platform": "Web",
    "language": "en-US",
    "statement": {
      "objectType": "StatementRef",
      "id": "2e6e54ac-62a6-4f14-a7a4-2e1f6a0a0d4c"
    },
    "extensions": {
      "http://example.com/extensions/location": "Building 1, Room 2"
    }
  },
  "authority": {
    "objectType": "Agent",
    "name": "LRS Admin",
    "mbox": "mailto:lrs@example.com"
  },
  "timestamp": "2025-08-29T18:35:00Z",
  "stored": "2025-08-29T18:35:10Z",
  "version": "1.0.3",
  "attachments": [
    {
      "usageType": "http://example.com/attachments/course-certificate",
      "display": { "en-US": "Certificate of Completion" },
      "description": { "en-US": "A certificate awarded for completing the course." },
      "contentType": "application/pdf",
      "length": 12345,
      "sha2": "2ef7bde608ce5404e97d5f042f95f89f1c232871",
      "fileUrl": "http://example.com/certificates/12345.pdf"
    }
  ]
}'

statement = JSON.parse(statement_json)

stmt = ActiveLrs::Xapi::Statement.new(statement)

puts "xAPI Statement Object"
stmt.instance_variables.each do |var|
  value = stmt.instance_variable_get(var)
  puts "#{var}: #{value.inspect}"
end

puts "-------------------------"

puts "xAPI Statement Hash"
stmt_hash = stmt.to_h
puts stmt_hash
puts "Hash Equality Check: #{statement == stmt_hash}"

statement.each do |k, v|
  if !stmt_hash.key?(k)
    puts "Missing key in stmt_hash: #{k}"
  elsif stmt_hash[k] != v
    puts "Value mismatch for key '#{k}': original=#{v.inspect}, to_h=#{stmt_hash[k].inspect}"
  end
end

# Find keys in stmt_hash that are not in statement
stmt_hash.each_key do |k|
  puts "Extra key in stmt_hash: #{k}" unless statement.key?(k)
end
