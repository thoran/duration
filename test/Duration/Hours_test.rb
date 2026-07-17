# test/duration/hours_test.rb

require_relative '../test_helper'

describe Duration::Hours do
  describe "initialization" do
    it "initializes with a float" do
      hours = Duration::Hours.new(2.5)
      _(hours.instance_variable_get(:@hours)).must_equal 2.5
      _(hours.instance_variable_get(:@hours)).must_be_kind_of Float
    end
  end

  describe "conversions" do
    subject do
      Duration::Hours.new(3)
    end

    it "converts to milliseconds" do
      ms = subject.to_milliseconds
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_f).must_equal 10800000.0
    end

    it "converts to seconds" do
      secs = subject.to_seconds
      _(secs).must_be_instance_of Duration::Seconds
      _(secs.to_f).must_equal 10800.0
    end

    it "converts to minutes" do
      mins = subject.to_minutes
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.to_f).must_equal 180.0
    end

    it "converts to days" do
      days = subject.to_days
      _(days).must_be_instance_of Duration::Days
      _(days.to_f).must_equal 0.125
    end

    it "converts to weeks" do
      weeks = subject.to_weeks
      _(weeks).must_be_instance_of Duration::Weeks
      _(weeks.to_f).must_be_close_to 0.017857, 0.000001
    end

    it "converts to months" do
      months = subject.to_months
      _(months).must_be_instance_of Duration::Months
      _(months.to_f).must_be_close_to 0.004107, 0.000001
    end

    it "returns itself for to_hours" do
      _((subject.to_hours).object_id).must_equal subject.object_id
    end
  end

  describe "time calculations" do
    it "calculates ago from current time" do
      hours = Duration::Hours.new(2)
      time_ago = hours.ago
      _(time_ago).must_be_instance_of Time
      _(Time.now - time_ago).must_be_close_to 7200.0, 1.0
    end

    it "calculates hence from current time" do
      hours = Duration::Hours.new(2)
      time_hence = hours.hence
      _(time_hence).must_be_instance_of Time
      _(time_hence - Time.now).must_be_close_to 7200.0, 1.0
    end
  end
end
