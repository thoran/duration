# test/duration/nanoseconds_test.rb

require_relative '../test_helper'

describe Duration::Nanoseconds do
  describe "initialization" do
    it "holds an integer without coercing to a float" do
      ns = Duration::Nanoseconds.new(1500)
      _(ns.instance_variable_get(:@nanoseconds)).must_equal 1500
      _(ns.instance_variable_get(:@nanoseconds)).must_be_kind_of Integer
    end
  end

  describe "conversions" do
    subject do
      Duration::Nanoseconds.new(2_000_000_000)
    end

    it "converts to microseconds" do
      us = subject.to_microseconds
      _(us).must_be_instance_of Duration::Microseconds
      _(us.to_f).must_equal 2_000_000.0
    end

    it "converts to milliseconds" do
      ms = subject.to_milliseconds
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_f).must_equal 2000.0
    end

    it "converts to seconds" do
      secs = subject.to_seconds
      _(secs).must_be_instance_of Duration::Seconds
      _(secs.to_f).must_equal 2.0
    end

    it "converts to minutes" do
      mins = subject.to_minutes
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.to_f).must_be_close_to 0.0333, 0.0001
    end

    it "converts to microseconds without truncating sub-microsecond precision" do
      us = Duration::Nanoseconds.new(1_500_500).to_microseconds
      _(us.to_f).must_equal 1500.5
    end

    it "returns itself for to_nanoseconds" do
      _((subject.to_nanoseconds).object_id).must_equal subject.object_id
    end
  end

  describe "time calculations" do
    it "calculates ago from current time" do
      ns = Duration::Nanoseconds.new(1_000_000_000)
      time_ago = ns.ago
      _(time_ago).must_be_instance_of Time
      _(Time.now - time_ago).must_be_close_to 1.0, 1.0
    end

    it "calculates hence from current time" do
      ns = Duration::Nanoseconds.new(1_000_000_000)
      time_hence = ns.hence
      _(time_hence).must_be_instance_of Time
      _(time_hence - Time.now).must_be_close_to 1.0, 1.0
    end
  end
end
