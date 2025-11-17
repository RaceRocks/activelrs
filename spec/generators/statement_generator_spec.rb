require "spec_helper"
require "generator_spec"
require "generators/active_lrs/statement/statement_generator"

RSpec.describe ActiveLrs::StatementGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)
  arguments %w[https://w3id.org/xapi/cmi5/context/categories/cmi5]

  before(:each) do
    prepare_destination

    # Set up Faraday test stubs
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get("/api/profile") do |env|
        [ 200, { "Content-Type" => "application/json" }, fixture_contents("cmi5_profile.json") ]
      end
    end

    # Stub Faraday.new to use the test adapter instead of the real connection
    allow(Faraday).to receive(:new).and_wrap_original do |original, *args, &block|
      # Call the real Faraday.new but override adapter to use the test stubs
      original.call(*args) do |f|
        f.adapter :test, stubs
        block.call(f) if block
      end
    end

    run_generator
  end

  it "creates a model file with class and instance methods" do
    assert_file "app/models/cmi5_profile_statement.rb" do |generator|
      assert_class_method :abandoned, generator
      assert_instance_method :abandoned, generator
    end
  end
end
