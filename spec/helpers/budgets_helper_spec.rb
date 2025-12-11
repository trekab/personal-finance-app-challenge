require "rails_helper"

RSpec.describe BudgetsHelper, type: :helper do
  # Shared examples for all helper methods
  shared_examples "a theme class helper" do |method_name, mapping, default_value|
    mapping.each do |theme, expected_class|
      it "returns #{expected_class.inspect} for #{theme.inspect}" do
        expect(helper.send(method_name, theme)).to eq(expected_class)
      end

      it "is case-insensitive for #{theme.inspect}" do
        expect(helper.send(method_name, theme.upcase)).to eq(expected_class)
        expect(helper.send(method_name, theme.capitalize)).to eq(expected_class)
        expect(helper.send(method_name, theme.swapcase)).to eq(expected_class)
      end
    end

    it "returns default for unknown themes" do
      expect(helper.send(method_name, "unknown")).to eq(default_value)
    end

    it "returns default when theme is nil" do
      expect(helper.send(method_name, nil)).to eq(default_value)
    end
  end

  # ------------------------------
  # border class
  # ------------------------------
  describe "#theme_border_class" do
    mapping = {
      "green"     => "border-teal-600",
      "yellow"    => "border-yellow-400",
      "cyan"      => "border-cyan-400",
      "navy"      => "border-slate-300",
      "red"       => "border-red-500",
      "purple"    => "border-purple-600",
      "turquoise" => "border-teal-500"
    }

    include_examples "a theme class helper", :theme_border_class, mapping, "border-gray-500"
  end

  # ------------------------------
  # text class
  # ------------------------------
  describe "#theme_text_class" do
    mapping = {
      "green"     => "text-teal-600",
      "yellow"    => "text-yellow-600",
      "cyan"      => "text-cyan-600",
      "navy"      => "text-slate-600",
      "red"       => "text-red-600",
      "purple"    => "text-purple-600",
      "turquoise" => "text-teal-600"
    }

    include_examples "a theme class helper", :theme_text_class, mapping, "text-gray-600"
  end

  # ------------------------------
  # background class
  # ------------------------------
  describe "#theme_bg_class" do
    mapping = {
      "green"     => "bg-teal-600",
      "yellow"    => "bg-yellow-400",
      "cyan"      => "bg-cyan-400",
      "navy"      => "bg-slate-300",
      "red"       => "bg-red-500",
      "purple"    => "bg-purple-600",
      "turquoise" => "bg-teal-500"
    }

    include_examples "a theme class helper", :theme_bg_class, mapping, "bg-gray-500"
  end

  # ------------------------------
  # fill class
  # ------------------------------
  describe "#theme_fill_class" do
    mapping = {
      "green"     => "fill-teal-600",
      "yellow"    => "fill-yellow-400",
      "cyan"      => "fill-cyan-400",
      "navy"      => "fill-slate-300",
      "red"       => "fill-red-500",
      "purple"    => "fill-purple-600",
      "turquoise" => "fill-teal-500"
    }

    include_examples "a theme class helper", :theme_fill_class, mapping, "fill-gray-500"
  end
end
