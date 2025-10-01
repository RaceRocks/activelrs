require "spec_helper"
require "securerandom"

RSpec.describe ActiveLrs::Xapi::Statement do
  include Helpers

  it "should serialize and deserialize JSON" do
    assert_serialize_and_deserialize(ActiveLrs::Xapi::Statement.new(JSON.parse(fixture_contents("statement.json"))))
  end

  it "should serialize and deserialize OBJECT" do
    targets = []
    activity = ActiveLrs::Xapi::Activity.new
    activity.id = "http://example.com/activity"
    targets << activity
    targets << get_agent("Target", "mbox", "mailto:target@example.com")
    ref = ActiveLrs::Xapi::StatementRef.new
    ref.id = SecureRandom.uuid
    targets << ref

    sub = ActiveLrs::Xapi::SubStatement.new
    sub.actor = get_agent("Sub", "mbox", "mailto:sub@example.com")
    verb = ActiveLrs::Xapi::Verb.new
    verb.id = "http://example.com/verb"
    sub.verb = verb
    activity = ActiveLrs::Xapi::Activity.new
    activity.id = "http://example.com/sub-activity"
    sub.object = activity
    targets << sub

    statement = ActiveLrs::Xapi::Statement.new
    statement.actor = get_agent("Joe", "mbox", "mailto:joe@example.com")
    attachment = ActiveLrs::Xapi::Attachment.new
    attachment.sha2 = "123"
    statement.attachments = [ attachment ]

    statement.authority = get_agent("Authority", "mbox", "mailto:authority@example.com")

    context = ActiveLrs::Xapi::Context.new({})
    context.language = "en-US"
    statement.context = context

    statement.id = SecureRandom.uuid

    result = ActiveLrs::Xapi::Result.new({})
    result.completion = true
    statement.result = result

    statement.stored = Time.now
    statement.timestamp = Time.now

    verb = ActiveLrs::Xapi::Verb.new({})
    verb.id = "http://example.com/verb"
    statement.verb = verb

    targets.each do |target|
      statement.object = target
      assert_serialize_and_deserialize(statement)
    end
  end
end
