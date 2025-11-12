require "active_lrs/statement"
require "json"
require "date"

RSpec.describe ActiveLrs::Statement do
  include Helpers
  describe "Statement query behavior" do
    let(:statements) do
      JSON.parse(fixture_contents("cmi5_statements.json")).map do |json|
        ActiveLrs::Xapi::Statement.new(json)
      end
    end

    before do
      allow(described_class).to receive(:data).and_return(statements)
    end

    context "Query methods" do
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
        results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/launched", "actor.name": "John Doe")
        results = results.to_a.map { |s| s.verb.id }
        expect(results.size).to eq(1)
        expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/launched")
      end

      it "can filter statements by an ISO8601 timestamp string" do
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
        results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/initialized")
                                      .since("2016-01-01T15:34:25.541Z")
        results = results.to_a.map { |s| s.verb.id }
        expect(results.size).to eq(1)
        expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/initialized")
      end

      it "orders statements by timestamps ascending" do
        results = ActiveLrs::Statement.order(timestamp: :asc)
        results = results.to_a.map { |s| s.timestamp }
        expect(results).to eq(results.sort)
      end

      it "orders statements by timestamps descending" do
        results = ActiveLrs::Statement.order(timestamp: :desc)
        results = results.to_a.map { |s| s.timestamp }
        expect(results).to eq(results.sort.reverse)
      end

      it "orders statements by verb.id ascending" do
        results = ActiveLrs::Statement.order("verb.id": :asc)
        results = results.to_a.map { |s| s.verb.id }
        expect(results).to eq(results.sort)
      end

      it "orders statements by verb.id descending" do
        results = ActiveLrs::Statement.order("verb.id": :desc)
        results = results.to_a.map { |s| s.verb.id }
        expect(results).to eq(results.sort.reverse)
      end

      it "can limit statements" do
        results = ActiveLrs::Statement.limit(1)
        expect(results.to_a.size).to eq(1)
      end
    end

    describe "Count Aggregation behaviour" do
      let(:statements) do
        JSON.parse(fixture_contents("cmi5_grouping_test_statements.json")).map do |json|
          ActiveLrs::Xapi::Statement.new(json)
        end
      end

      before do
        allow(described_class).to receive(:data).and_return(statements)
      end

      context "Basic counting" do
        it "counts all statements" do
          results = ActiveLrs::Statement.count
          expect(results).to eq(6)
        end

        it "counts simple queries" do
          results = ActiveLrs::Statement.where("actor.name": "Alice").count
          expect(results).to eq(3)
        end

        it "counts chained queries" do
          results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/initialized")
                                        .since("2025-01-01T10:00:00Z")
                                        .count
          expect(results).to eq(2)
        end

        it "counts with single condition" do
          results = ActiveLrs::Statement.count("actor.name": "Bob")
          expect(results).to eq(2)
        end

        it "counts with multiple conditions" do
          results = ActiveLrs::Statement.count("actor.name": "Bob", "verb.id": "http://adlnet.gov/expapi/verbs/completed")
          expect(results).to eq(1)
        end

        it "raises error when chaining after count" do
          expect do
            results = ActiveLrs::Statement.where("actor.name": "Alice")
                                          .count
                                          .where("verb.id": "http://adlnet.gov/expapi/verbs/terminated")
          end.to raise_error(NoMethodError)
        end
      end

      context "Grouped counting" do
        it "groups and counts all statements" do
          results = ActiveLrs::Statement.group("actor.name").count
          expect(results).to eq({ "Alice" => 3, "Bob" => 2, "Charlie" => 1 })
        end

        it "groups and counts from a simple query" do
          results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/initialized")
                                        .group("actor.name")
                                        .count
          expect(results).to eq({ "Alice" => 1, "Bob" => 1 })
        end

        it "groups and counts via count filters" do
          results = ActiveLrs::Statement.group("actor.name").count("verb.id": "http://adlnet.gov/expapi/verbs/completed")
          expect(results).to eq({ "Bob" => 1 })
        end

        it "groups and counts with chained query" do
          results = ActiveLrs::Statement.where("actor.name": "Alice")
                                        .since("2025-01-03T15:00:00Z")
                                        .group("verb.id")
                                        .count
          expect(results).to eq({ "http://adlnet.gov/expapi/verbs/terminated" => 1 })
        end

        it "counts nil for a completely missing field" do
          results = ActiveLrs::Statement.group("nonexistent.field").count
          expect(results).to eq({ nil => 6 })
        end

        it "counts statements with partially missing fields" do
          results = ActiveLrs::Statement.group("object.definition.description").count
          expect(results).to eq({
            nil => 1,
            { "en-US" => "Introductory math course" } => 4,
            { "en-US" => "Intermediate science course" } => 1
          })
        end

        it "returns query object with @group_by set" do
          results = ActiveLrs::Statement.group("actor.name")
          expect(results.instance_variable_get(:@group_by)).to eq("actor.name")
        end
      end

      context "Ordering and limiting grouped results" do
        it "orders ascending by count" do
          results = ActiveLrs::Statement.order(count: :asc).group("actor.name").count
          expect(results).to eq({ "Charlie" => 1, "Bob" => 2, "Alice" => 3 })
        end

        it "orders descending by count" do
          results = ActiveLrs::Statement.order(count: :desc).group("actor.name").count
          expect(results).to eq({ "Alice" => 3, "Bob" => 2, "Charlie" => 1 })
        end

        it "applies limit after ordering ascending" do
          results = ActiveLrs::Statement.order(count: :asc).limit(1).group("actor.name").count
          expect(results).to eq({ "Charlie" => 1 })
        end

        it "applies limit after ordering descending" do
          results = ActiveLrs::Statement.order(count: :desc).limit(1).group("actor.name").count
          expect(results).to eq({ "Alice" => 3 })
        end
      end

      context "Grouped by timestamp counting" do
        it "groups by day" do
          results = ActiveLrs::Statement.group("timestamp", period: :day).count
          expect(results).to eq({ "2025-01-01" => 3, "2025-01-02" => 2, "2025-01-03" => 1 })
        end

        it "groups by week" do
          results = ActiveLrs::Statement.group("timestamp", period: :week).count
          expect(results).to eq({ "2025-W01" => 6 })
        end

        it "groups by month" do
          results = ActiveLrs::Statement.group("timestamp", period: :month).count
          expect(results).to eq({ "2025-01" => 6 })
        end

        it "filters and groups within a time range" do
          results = ActiveLrs::Statement.since("2025-01-02T00:00:00Z")
                                        .group("timestamp", period: :day)
                                        .count
          expect(results).to eq({ "2025-01-02" => 2, "2025-01-03" => 1 })
        end

        it "returns empty results for future-only ranges" do
          results = ActiveLrs::Statement.since("2030-01-01T00:00:00Z")
                                        .group("timestamp", period: :day)
                                        .count
          expect(results).to eq({})
        end

        it "groups by day after filtering and ordering" do
          results = ActiveLrs::Statement.where("actor.name": "Alice")
                                        .order(timestamp: :asc)
                                        .group("timestamp", period: :day)
                                        .count
          expect(results).to eq({ "2025-01-01" => 2, "2025-01-03" => 1 })
        end

        it "limits grouped results after ordering descending" do
          results = ActiveLrs::Statement.group("actor.name")
                                        .order(count: :desc)
                                        .limit(2)
                                        .count
          expect(results).to eq({ "Alice" => 3, "Bob" => 2 })
        end

        it "filters, groups by week, and limits results" do
          results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/initialized")
                                        .group("timestamp", period: :week)
                                        .order(count: :desc)
                                        .limit(1)
                                        .count
          expect(results).to eq({ "2025-W01" => 2 })
        end

        it "filters by verb and actor, groups by month, and orders ascending" do
          results = ActiveLrs::Statement.where("actor.name": "Bob")
                                        .where("verb.id": "http://adlnet.gov/expapi/verbs/completed")
                                        .group("timestamp", period: :month)
                                        .order(count: :asc)
                                        .count
          expect(results).to eq({ "2025-01" => 1 })
        end
      end
    end

    describe "Average Aggregation behaviour" do
      let(:statements) do
        JSON.parse(fixture_contents("cmi5_average_test_statements.json")).map do |json|
          ActiveLrs::Xapi::Statement.new(json)
        end
      end

      context "Basic averaging" do
        it "can average all statements" do
          results = ActiveLrs::Statement.average("result.score.raw")
          expect(results.round(3)).to eq(74.800)
        end

        it "can average simple queries" do
          results = ActiveLrs::Statement.where("object.id": "http://example.com/activities/quiz-1").average("result.score.raw")
          expect(results.round(3)).to eq(62.667)
        end

        it "can average chained queries" do
          results = ActiveLrs::Statement
            .where("object.id": "http://example.com/activities/quiz-1")
            .since("2025-10-03T00:00:00Z")
            .average("result.score.raw")
          expect(results.round(3)).to eq(58.000)
        end

        it "can average statements given multiple conditions" do
          results = ActiveLrs::Statement
            .where("object.id": "http://example.com/activities/quiz-1")
            .where("verb.id": "http://adlnet.gov/expapi/verbs/passed")
            .average("result.score.raw")
          expect(results.round(3)).to eq(85.000)
        end

        it "cannot average empty parameter" do
          expect do
            ActiveLrs::Statement
              .where("object.id": "http://example.com/activities/quiz-1")
              .average
          end.to raise_error(ArgumentError)
        end

        it "would return 0.0 for unknown parameter" do
          results = ActiveLrs::Statement.average("unknown.parameter")
          expect(results).to eq(0.0)
        end

        it "cannot query a averaged query" do
          expect do
            ActiveLrs::Statement.where("actor.name": "Alice")
              .average("unknown.parameter")
              .where("verb.id": "http://adlnet.gov/expapi/verbs/terminated")
          end.to raise_error(NoMethodError)
        end
      end

      context "Grouped averaging" do
        it "can group and average all statements" do
          results = ActiveLrs::Statement
            .group("object.id")
            .average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-1" => 62.667,
            "http://example.com/activities/quiz-2" => 73.0,
            "http://example.com/activities/course-1" => 83.333,
            "http://example.com/activities/quiz-3" => 91.0
          })
        end

        it "can group and average statements from a simple query" do
          results = ActiveLrs::Statement
            .where("object.id": "http://example.com/activities/quiz-1")
            .group("verb.id")
            .average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            "http://adlnet.gov/expapi/verbs/passed" => 85.0,
            "http://adlnet.gov/expapi/verbs/failed" => 45.0,
            "http://adlnet.gov/expapi/verbs/attempted" => 58.0
          })
        end

        it "can group and average statements from a chained query with multiple conditions" do
          results = ActiveLrs::Statement
            .where("object.id": "http://example.com/activities/quiz-1")
            .since("2025-10-03T00:00:00Z")
            .group("verb.id")
            .average("result.score.raw")

          expect_hash_with_rounded_values(results, { "http://adlnet.gov/expapi/verbs/attempted" => 58.0 })
        end

        it "averages nil for a completely missing field" do
          results = ActiveLrs::Statement.group("nonexistent.field").average("result.score.raw")

          expect_hash_with_rounded_values(results, { nil => 74.800 })
        end

        it "averages statements with partially missing fields" do
          results = ActiveLrs::Statement
            .where("object.id": "http://example.com/activities/quiz-1")
            .group("verb.display")
            .average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            { "en-US" => "passed" } => 85.0,
            { "en-US" => "failed" } => 45.0,
            nil => 58.0 })
        end

        it "orders grouped results ascending by average" do
          results = ActiveLrs::Statement.order(average: :asc).group("object.id").average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-1" => 62.667,
            "http://example.com/activities/quiz-2" => 73.0,
            "http://example.com/activities/course-1" => 83.333,
            "http://example.com/activities/quiz-3" => 91.0
          })
        end

        it "order grouped results descending by average" do
          results = ActiveLrs::Statement.order(average: :desc).group("object.id").average("result.score.raw")
          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-3" => 91.0,
            "http://example.com/activities/course-1" => 83.333,
            "http://example.com/activities/quiz-2" => 73.0,
            "http://example.com/activities/quiz-1" => 62.667
          })
        end

        it "applies limit after ordering ascending" do
          results = ActiveLrs::Statement.order(average: :asc).limit(1).group("object.id").average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-1" => 62.667
          })
        end

        it "applies limit after ordering descending" do
          results = ActiveLrs::Statement.order(average: :desc).limit(2).group("object.id").average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-3" => 91.0,
            "http://example.com/activities/course-1" => 83.333
          })
        end
      end
    end
  end
end
