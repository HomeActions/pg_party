# frozen_string_literal: true

require "spec_helper"

RSpec.describe PgParty::Cache do
  let(:block) { ->{ :new_value } }

  subject(:cache) { described_class }
  subject(:fetch_model) { cache.fetch_model(12345678901, :child, &block) }
  subject(:fetch_partitions) { cache.fetch_partitions(12345678901, &block) }

  around do |example|
    cache.clear!
    example.run
    cache.clear!
  end

  describe ".clear!" do
    before do
      cache.fetch_partitions(12345678901) { :old_value }
      cache.fetch_model(12345678901, :child) { :old_value }
    end

    subject { cache.clear! }

    it { is_expected.to be_nil }

    it "clears cached partitions" do
      subject
      expect(fetch_partitions).to eq(:new_value)
    end

    it "clears cached models" do
      subject
      expect(fetch_model).to eq(:new_value)
    end
  end

  describe ".fetch_model" do
    subject { fetch_model }

    context "when key does not exist" do
      it { is_expected.to eq(:new_value) }

      it "executes block" do
        expect(block).to receive(:call).and_call_original
        subject
      end
    end

    context "when key exists" do
      before do
        cache.fetch_model(12345678901, :child) { :old_value }
      end

      it { is_expected.to eq(:old_value) }

      it "does not execute block" do
        expect(block).to_not receive(:call)
        subject
      end
    end
  end

  describe ".fetch_partitions" do
    subject { fetch_partitions }

    context "when key does not exist" do
      it { is_expected.to eq(:new_value) }

      it "executes block" do
        expect(block).to receive(:call).and_call_original
        subject
      end
    end

    context "when key exists" do
      before do
        cache.fetch_partitions(12345678901) { :old_value }
      end

      it { is_expected.to eq(:old_value) }

      it "does not execute block" do
        expect(block).to_not receive(:call)
        subject
      end
    end
  end
end
