require "spec_helper"
require "generator_spec"
require "generators/active_lrs/statement/statement_generator"

RSpec.describe ActiveLrs::StatementGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)
  arguments %w[https://w3id.org/xapi/cmi5/context/categories/cmi5]

  before(:all) do
    prepare_destination
    run_generator
  end

  it "creates a model file with class and instance methods" do
    assert_file "app/models/cmi5_profile_statement.rb" do |generator|
      assert_class_method :abandoned, generator
      assert_instance_method :abandoned, generator
    end
  end
end
