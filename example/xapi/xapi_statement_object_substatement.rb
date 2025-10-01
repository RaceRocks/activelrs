#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "active_lrs"

statement_json = '{
  "id": "9e4a50b2-3d6f-44fb-927f-9c2e32c0191f",
  "actor": {
    "objectType": "Agent",
    "name": "Jane Doe",
    "mbox": "mailto:jane.doe@example.com"
  },
  "verb": {
    "id": "http://adlnet.gov/expapi/verbs/asserted",
    "display": { "en-US": "asserted" }
  },
  "object": {
    "objectType": "SubStatement",
    "actor": {
      "objectType": "Agent",
      "name": "John Smith",
      "mbox": "mailto:john.smith@example.com"
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
        "type": "http://adlnet.gov/expapi/activities/course"
      }
    },
    "result": {
      "score": {
        "scaled": 0.85,
        "raw": 85,
        "min": 0,
        "max": 100
      },
      "success": true,
      "completion": true,
      "response": "I passed!",
      "duration": "PT1H30M"
    },
    "context": {
      "registration": "b6c50b77-bf44-4f21-9d4b-1a93b6123456",
      "platform": "Mobile App",
      "language": "en-US",
      "extensions": {
        "http://example.com/extensions/device": "iPhone"
      }
    }
  },
  "context": {
    "instructor": {
      "objectType": "Agent",
      "name": "Professor Oak",
      "mbox": "mailto:oak@example.com"
    }
  },
  "timestamp": "2025-08-29T19:05:00Z",
  "version": "1.0.3"
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
