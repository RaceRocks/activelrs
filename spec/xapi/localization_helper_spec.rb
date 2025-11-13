require "spec_helper"

# Define a dummy I18n if it’s not already loaded
unless defined?(I18n)
  module I18n
    def self.locale
      :en
    end
  end
end

RSpec.describe ActiveLrs::Xapi::LocalizationHelper do
  # Create a dummy class to include the module
  class DummyClass
    include ActiveLrs::Xapi::LocalizationHelper
  end

  let(:helper) { DummyClass.new }

  describe "get_localized_value" do
    let(:lang_map) do
      {
        "en-US" => "Hello",
        "en-CA" => "Howdy",
        "fr-FR" => "Bonjour",
        "fr-CA" => "Salut",
        "es" => "Hola"
      }
    end

    context "when exact locale match exists" do
      it "returns the exact match" do
        expect(helper.get_localized_value(lang_map, "en-US")).to eq("Hello")
        expect(helper.get_localized_value(lang_map, "fr-FR")).to eq("Bonjour")
      end
    end

    context "when locale is base language only" do
      it "returns the first matching regional variant" do
        expect(helper.get_localized_value(lang_map, "en")).to eq("Howdy")
        expect(helper.get_localized_value(lang_map, "fr")).to eq("Salut")
      end
    end

    context "when locale is not present" do
      it "returns the first available value in the map" do
        expect(helper.get_localized_value(lang_map, "de")).to eq("Hello")
      end
    end

    context "when locale is nil" do
      it "returns the value matching I18n.locale if available" do
        allow(ActiveLrs.configuration).to receive(:default_locale).and_return(nil)
        allow(I18n).to receive(:locale).and_return("fr-FR")
        expect(helper.get_localized_value(lang_map)).to eq("Bonjour")
      end
    end

    context "when lang_map is nil or empty" do
      it "returns 'undefined' for nil" do
        expect(helper.get_localized_value(nil, "en")).to eq("undefined")
      end

      it "returns 'undefined' for empty hash" do
        expect(helper.get_localized_value({}, "en")).to eq("undefined")
      end
    end

    context "when system default locale is used as fallback" do
      before do
        allow(ActiveLrs.configuration).to receive(:default_locale).and_return("es")
      end

      it "returns default locale value if requested locale not found" do
        expect(helper.get_localized_value(lang_map, "de")).to eq("Hola")
      end
    end
  end
end
