RSpec.shared_context "with loaded statements fixture" do |fixture|
  let(:statements) do
    JSON.parse(fixture_contents(fixture)).map { |json| ActiveLrs::Xapi::Statement.new(json) }
  end
  before { allow(described_class).to receive(:data).and_return(statements) }
end
