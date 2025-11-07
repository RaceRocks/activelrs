module Helpers
  def get_agent(name, type, value)
    agent = ActiveLrs::Xapi::Agent.new(name: name)
    case type
    when :mbox
      agent.mbox =  value
    when :open_id
      agent.open_id = value
    when :mbox_sha1_sum
      agent.mbox_sha1_sum = value
    when :account
      parts = value.split("|")
      account = ActiveLrs::Xapi::AgentAccount.new(home_page: parts.first, name: parts.last)
      agent.account = account
    end
    agent
  end

  def create_interaction_component(id, description)
    component = ActiveLrs::Xapi::InteractionComponent.new
    component.id = id
    map = {}
    map["en-US"] = description
    component.description = map
    [ component ]
  end

  def assert_serialize_and_deserialize(object)
    hash = object.to_h
    new_definition = object.class.new(hash)
    expect(hash).to eq(new_definition.to_h)
  end

  def expect_hash_with_rounded_values(actual, expected, precision: 3)
    rounded = actual.transform_values { |v| v.round(precision) }
    expect(rounded).to eq(expected)
  end
end
