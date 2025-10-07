require "active_lrs/statement"
require "json"
require "date"

RSpec.describe ActiveLrs::Statement do
  include Helpers
  let(:statements) do
    JSON.parse(fixture_contents("cmi5_statements.json")).map do |json|
      ActiveLrs::Xapi::Statement.new(json)
    end
  end

  before do
    allow(described_class).to receive(:data).and_return(statements)
  end

  context "Query Methods" do
    it "returns all statements with .all" do
      results = ActiveLrs::Statement.all
      expect(results.to_a.size).to eq(5)
      expect(results.to_a.map { |s| s.actor.name }).to all(eq("John Doe"))
    end

    it "iterates over statements with .each" do
      actors = []
      ActiveLrs::Statement.all.each { |s| actors << s.actor.name }
      expect(actors.size).to eq(5)
      expect(actors).to all(eq("John Doe"))
    end

    it "returns nothing if no statements match the filter" do
      results = ActiveLrs::Statement.where("actor.name": "Nonexistent Learner")
      expect(results.to_a).to eq([])
    end

    it "filters by a verb when passed as a string" do
      results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/passed")
      results = results.to_a.map { |s| s.verb.id }
      expect(results.size).to eq(1)
      expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/passed")
    end

    it "chains string conditions to filter statements" do
      results = ActiveLrs::Statement
                .where("verb.id": "http://adlnet.gov/expapi/verbs/launched", "actor.name": "John Doe")

      results = results.to_a.map { |s| s.verb.id }
      expect(results.size).to eq(1)
      expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/launched")
    end

    it "can filter statements by a ISO8601 timestamp string" do
      results = ActiveLrs::Statement.since("2025-01-01T15:34:43.401Z")
      results = results.to_a.map { |s| s.verb.id }
      expect(results.size).to eq(1)
      expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/terminated")
    end

    it "can filter statements by a Ruby Time object" do
      results = ActiveLrs::Statement.since(Time.new(2025))
      results = results.to_a.map { |s| s.verb.id }
      expect(results.size).to eq(1)
      expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/terminated")
    end

    it "can filter statements by a timestamp and verbs" do
      results = ActiveLrs::Statement
                .where("verb.id": "http://adlnet.gov/expapi/verbs/initialized")
                .since("2016-01-01T15:34:25.541Z")
      results = results.to_a.map { |s| s.verb.id }
      expect(results.size).to eq(1)
      expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/initialized")
    end

    it "can order statements by timestamps in ascending order" do
      results = ActiveLrs::Statement.order(timestamp: :asc)
      results = results.to_a.map { |s| s.timestamp }
      expect(results).to eq(results.sort)
    end

    it "can order statements by timestamps in descending order" do
      results = ActiveLrs::Statement.order(timestamp: :desc)
      results = results.to_a.map { |s| s.timestamp }
      expect(results).to eq(results.sort.reverse)
    end

    it "can order statements by verb.id in ascending order" do
      results = ActiveLrs::Statement.order("verb.id": :asc)
      results = results.to_a.map { |s| s.verb.id }
      expect(results).to eq(results.sort)
    end

    it "can order statements by verb.id in descending order" do
      results = ActiveLrs::Statement.order("verb.id": :desc)
      results = results.to_a.map { |s| s.verb.id }
      expect(results).to eq(results.sort.reverse)
    end

    it "can limit statements" do
      results = ActiveLrs::Statement.limit(1)
      expect(results.to_a.size).to eq(1)
    end

    it "can count statements" do
      results = ActiveLrs::Statement.count
      expect(results).to eq(5)
    end

    it "can count simple queries" do
      results = ActiveLrs::Statement.where("actor.name": "John Doe").count
      expect(results).to eq(5)
    end

    it "can count chained queries" do
      results = ActiveLrs::Statement
        .where("verb.id": "http://adlnet.gov/expapi/verbs/initialized")
        .since("2016-01-01T15:34:25.541Z")
        .count
      expect(results).to eq(1)
    end

    it "respects limit when counting" do
      results = ActiveLrs::Statement.limit(3).count
      expect(results).to eq(3)
    end

    it "cannot query a counted query" do
      expect do
        ActiveLrs::Statement.where("actor.name": "John Doe")
                            .count
                            .where("verb.id": "http://adlnet.gov/expapi/verbs/launched")
      end.to raise_error(NoMethodError)
    end
  end
end
