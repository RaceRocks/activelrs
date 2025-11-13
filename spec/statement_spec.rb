require "active_lrs/statement"
require "json"
require "date"

RSpec.describe ActiveLrs::Statement do
  include Helpers
  describe "Query behaviour" do
    include_context "with loaded statements fixture", "cmi5_statements.json"

    context "when filtering statements" do
      it "returns all statements" do
        results = ActiveLrs::Statement.all.to_a
        expect(results.size).to eq(5)
        expect(results.map { |s| s.actor.name }).to all(eq("John Doe"))
      end

      it "returns no statements when no match" do
        results = ActiveLrs::Statement.where("actor.name": "Nonexistent Learner").to_a
        expect(results).to eq([])
      end

      it "filters by verb" do
        results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/passed").to_a.map { |s| s.verb.id }
        expect(results.size).to eq(1)
        expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/passed")
      end

      it "chains multiple filters" do
        results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/launched", "actor.name": "John Doe").to_a.map { |s| s.verb.id }
        expect(results.size).to eq(1)
        expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/launched")
      end

      it "filter by an ISO8601 timestamp string" do
        results = ActiveLrs::Statement.since("2025-01-01T15:34:43.401Z").to_a.map { |s| s.verb.id }
        expect(results.size).to eq(1)
        expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/terminated")
      end

      it "filter by a Ruby Time object" do
        results = ActiveLrs::Statement.since(Time.new(2025)).to_a.map { |s| s.verb.id }
        expect(results.size).to eq(1)
        expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/terminated")
      end

      it "filter by a timestamp and verbs" do
        results = ActiveLrs::Statement.where("verb.id": "http://adlnet.gov/expapi/verbs/initialized")
                                      .since("2016-01-01T15:34:25.541Z")
                                      .to_a.map { |s| s.verb.id }
        expect(results.size).to eq(1)
        expect(results).to contain_exactly("http://adlnet.gov/expapi/verbs/initialized")
      end
    end

    context "when iterating statements" do
      it "iterates over statements with .each" do
        actors = []
        ActiveLrs::Statement.all.each { |s| actors << s.actor.name }
        expect(actors.size).to eq(5)
        expect(actors).to all(eq("John Doe"))
      end
    end

    context "when ordering statements" do
      it "orders by timestamps ascending" do
        results = ActiveLrs::Statement.order(timestamp: :asc)
        results = results.to_a.map { |s| s.timestamp }
        expect(results).to eq(results.sort)
      end

      it "orders by timestamps descending" do
        results = ActiveLrs::Statement.order(timestamp: :desc)
        results = results.to_a.map { |s| s.timestamp }
        expect(results).to eq(results.sort.reverse)
      end

      it "orders by verb.id ascending" do
        results = ActiveLrs::Statement.order("verb.id": :asc)
        results = results.to_a.map { |s| s.verb.id }
        expect(results).to eq(results.sort)
      end

      it "orders by verb.id descending" do
        results = ActiveLrs::Statement.order("verb.id": :desc)
        results = results.to_a.map { |s| s.verb.id }
        expect(results).to eq(results.sort.reverse)
      end
    end

    context "when limiting statements" do
      it "limits statements" do
        results = ActiveLrs::Statement.limit(1).to_a
        expect(results.size).to eq(1)
      end
    end
  end

  describe "Count aggregation behaviour" do
    include_context "with loaded statements fixture", "cmi5_grouping_test_statements.json"

    context "when performing basic counts" do
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

      it "counts with single filter" do
        results = ActiveLrs::Statement.count("actor.name": "Bob")
        expect(results).to eq(2)
      end

      it "counts with multiple filtering" do
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

    context "when performing grouped counts" do
      it "groups and counts all statements" do
        results = ActiveLrs::Statement.group("actor.name").count
        expect(results).to eq({ "Alice" => 3, "Bob" => 2, "Charlie" => 1 })
      end

      it "groups and counts from simple query" do
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

      it "sets @group_by in query object" do
        results = ActiveLrs::Statement.group("actor.name")
        expect(results.instance_variable_get(:@group_by)).to eq("actor.name")
      end

      context "with ordering and limiting" do
        it "orders grouped ascending by count" do
          results = ActiveLrs::Statement.order(count: :asc).group("actor.name").count
          expect(results).to eq({ "Charlie" => 1, "Bob" => 2, "Alice" => 3 })
        end

        it "orders grouped descending by count" do
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

      context "with time-based grouping" do
        it "groups counts by day" do
          results = ActiveLrs::Statement.group("timestamp", period: :day).count
          expect(results).to eq({ "2025-01-01" => 3, "2025-01-02" => 2, "2025-01-03" => 1 })
        end

        it "groups counts by week" do
          results = ActiveLrs::Statement.group("timestamp", period: :week).count
          expect(results).to eq({ "2025-W01" => 6 })
        end

        it "groups counts by month" do
          results = ActiveLrs::Statement.group("timestamp", period: :month).count
          expect(results).to eq({ "2025-01" => 6 })
        end

        it "filters and groups within time range" do
          results = ActiveLrs::Statement.since("2025-01-02T00:00:00Z")
                                        .group("timestamp", period: :day)
                                        .count
          expect(results).to eq({ "2025-01-02" => 2, "2025-01-03" => 1 })
        end

        it "returns empty for future-only ranges" do
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
  end

  describe "Average aggregation behaviour" do
    include_context "with loaded statements fixture", "cmi5_average_test_statements.json"

    context "when performing basic averages" do
      it "averages all statements" do
        results = ActiveLrs::Statement.average("result.score.raw")
        expect(results.round(3)).to eq(74.800)
      end

      it "averages simple queries" do
        results = ActiveLrs::Statement.where("object.id": "http://example.com/activities/quiz-1").average("result.score.raw")
        expect(results.round(3)).to eq(62.667)
      end

      it "averages chained queries" do
        results = ActiveLrs::Statement
          .where("object.id": "http://example.com/activities/quiz-1")
          .since("2025-10-03T00:00:00Z")
          .average("result.score.raw")
        expect(results.round(3)).to eq(58.000)
      end

      it "averages statements given multiple conditions" do
        results = ActiveLrs::Statement
          .where("object.id": "http://example.com/activities/quiz-1")
          .where("verb.id": "http://adlnet.gov/expapi/verbs/passed")
          .average("result.score.raw")
        expect(results.round(3)).to eq(85.000)
      end

      it "raises error when averaging empty parameter" do
        expect do
          ActiveLrs::Statement
            .where("object.id": "http://example.com/activities/quiz-1")
            .average
        end.to raise_error(ArgumentError)
      end

      it "returns 0.0 for unknown parameter" do
        results = ActiveLrs::Statement.average("unknown.parameter")
        expect(results).to eq(0.0)
      end

      it "raises error when querying after averaging" do
        expect do
          ActiveLrs::Statement.where("actor.name": "Alice")
            .average("unknown.parameter")
            .where("verb.id": "http://adlnet.gov/expapi/verbs/terminated")
        end.to raise_error(NoMethodError)
      end
    end

    context "when performing grouped averages" do
      it "groups and averages all statements" do
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

      it "groups and averages statements from simple query" do
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

      it "groups and averages statements from chained query with multiple conditions" do
        results = ActiveLrs::Statement
          .where("object.id": "http://example.com/activities/quiz-1")
          .since("2025-10-03T00:00:00Z")
          .group("verb.id")
          .average("result.score.raw")

        expect_hash_with_rounded_values(results, { "http://adlnet.gov/expapi/verbs/attempted" => 58.0 })
      end

      it "averages nil for missing field" do
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

      context "when ordering and limiting" do
        it "orders grouped averages ascending" do
          results = ActiveLrs::Statement.order(average: :asc).group("object.id").average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-1" => 62.667,
            "http://example.com/activities/quiz-2" => 73.0,
            "http://example.com/activities/course-1" => 83.333,
            "http://example.com/activities/quiz-3" => 91.0
          })
        end

        it "orders grouped averages descending" do
          results = ActiveLrs::Statement.order(average: :desc).group("object.id").average("result.score.raw")
          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-3" => 91.0,
            "http://example.com/activities/course-1" => 83.333,
            "http://example.com/activities/quiz-2" => 73.0,
            "http://example.com/activities/quiz-1" => 62.667
          })
        end

        it "applies limit after ascending order" do
          results = ActiveLrs::Statement.order(average: :asc).limit(1).group("object.id").average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-1" => 62.667
          })
        end

        it "applies limit after descending order" do
          results = ActiveLrs::Statement.order(average: :desc).limit(2).group("object.id").average("result.score.raw")

          expect_hash_with_rounded_values(results, {
            "http://example.com/activities/quiz-3" => 91.0,
            "http://example.com/activities/course-1" => 83.333
          })
        end
      end
    end

    describe "Distinct selection behaviour" do
      let(:statements) do
        JSON.parse(fixture_contents("cmi5_grouping_test_statements.json")).map do |json|
          ActiveLrs::Xapi::Statement.new(json)
        end
      end

      before do
        allow(described_class).to receive(:data).and_return(statements)
      end

      context "Basic distinct selection" do
        it "returns nothing if the attribute does not exist" do
          results = ActiveLrs::Statement.select("nonexistent.field").to_a
          expect(results).to eq([])
        end

        it "returns all actor names" do
          results = ActiveLrs::Statement.select("actor.name").to_a
          expect(results).to eq(["Alice", "Bob", "Alice", "Charlie", "Alice", "Bob"])
        end

        it "returns distinct actor names" do
          results = ActiveLrs::Statement.select("actor.name").distinct.to_a
          expect(results).to eq(["Alice", "Bob", "Charlie"])
        end
      end

      context "Distinct select chaining" do
        it "returns distinct filtered actors" do
          results = ActiveLrs::Statement.where("actor.name": "Alice").select("actor.name").distinct.to_a
          expect(results).to eq(["Alice"])
        end

        it "orders distinct results alphabetically ascending" do
          results = ActiveLrs::Statement.select("actor.name").distinct.order("actor.name": :asc).to_a
          expect(results).to eq(["Alice", "Bob", "Charlie"])
        end

        it "orders distinct results alphabetically descending" do
          results = ActiveLrs::Statement.select("actor.name").distinct.order("actor.name": :desc).to_a
          expect(results).to eq(["Charlie", "Bob", "Alice"])
        end
      end

      context "Distinct selection with grouping and counting" do
        it "groups by course ID and counts distinct verbs" do
          results = ActiveLrs::Statement.group("object.id").select("verb.id").distinct.count
          puts("groups by course ID and counts distinct verbs: #{results.inspect}")
          expect(results).to eq({
            "http://example.org/courses/math101" => 3,
            "http://example.org/courses/science201" => 2
          })
        end

        it "groups by course ID and counts distinct actors" do
          results = ActiveLrs::Statement.group("object.id").select("actor.name").distinct.count
          puts("groups by course ID and counts distinct actors: #{results.inspect}") 
          expect(results).to eq({
            "http://example.org/courses/math101" => 2,
            "http://example.org/courses/science201" => 2
          })
        end

        it "groups by timestamp day and counts distinct verbs" do
          results = ActiveLrs::Statement.group("timestamp", period: :day).select("verb.id").distinct.count
          puts("groups by timestamp day and counts distinct verbs: #{results.inspect}")
          expect(results).to eq({
            "2025-01-01" => 2,
            "2025-01-02" => 2,
            "2025-01-03" => 1
          })
        end

        it "groups by timestamp week and counts distinct actors" do
          results = ActiveLrs::Statement.group("timestamp", period: :week).select("actor.name").distinct.count
          puts("groups by timestamp week and counts distinct actors: #{results.inspect}")
          expect(results).to eq({
            "2025-W01" => 3
          })
        end

        it "groups by timestamp month and counts distinct actors" do
          results = ActiveLrs::Statement.group("timestamp", period: :month).select("actor.name").distinct.count
          puts("groups by timestamp month and counts distinct actors: #{results.inspect}")
          expect(results).to eq({
            "2025-01" => 3
          })
        end
      end
    end
  end

  describe "Fetch localized value behaviour" do
    include_context "with loaded statements fixture", "cmi5_locale_test_statements.json"

    context "when fetching localized values" do
      it "returns the localized value for a given locale" do
        value = ActiveLrs::Statement.fetch_localized_value(
          "object.id", "http://example.com/activities/math", "object.definition.name", "fr-FR"
        )
        expect(value).to eq("Mathématiques")
      end

      it "returns the localized value for a given base language" do
        value = ActiveLrs::Statement.fetch_localized_value(
          "object.id", "http://example.com/activities/math", "object.definition.name"
        )
        expect(value).to eq("Math")
      end

      it "returns the first available value if locale is not provided" do
        value = ActiveLrs::Statement.fetch_localized_value(
          "actor.name", "Alice", "object.definition.name"
        )
        expect(value).to eq("Science")
      end

      it "returns nil when no matching statement is found" do
        value = ActiveLrs::Statement.fetch_localized_value(
          "actor.name", "Charlie", "object.definition.name", "en-US"
        )
        expect(value).to eq(nil)
      end

      it "returns nil when the target attribute is missing" do
        value = ActiveLrs::Statement.fetch_localized_value(
          "actor.name", "Bob", "object.definition.description", "en-US"
        )
        expect(value).to eq(nil)
      end
    end
  end
end
