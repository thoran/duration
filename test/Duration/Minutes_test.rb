# test/duration/minutes_test.rb

require_relative '../test_helper'

describe Duration::Minutes do
  describe "initialization" do
    it "initializes with a float" do
      mins = Duration::Minutes.new(30.5)
      _(mins.instance_variable_get(:@minutes)).must_equal 30.5
      _(mins.instance_variable_get(:@minutes)).must_be_kind_of Float
    end
  end

  describe "conversions" do
    subject do
      Duration::Minutes.new(90)
    end

    it "converts to milliseconds" do
      ms = subject.to_milliseconds
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_f).must_equal 5400000.0
    end

    it "converts to seconds" do
      secs = subject.to_seconds
      _(secs).must_be_instance_of Duration::Seconds
      _(secs.to_f).must_equal 5400.0
    end

    it "converts to hours" do
      hours = subject.to_hours
      _(hours).must_be_instance_of Duration::Hours
      _(hours.to_f).must_equal 1.5
    end

    it "converts to days" do
      days = subject.to_days
      _(days).must_be_instance_of Duration::Days
      _(days.to_f).must_equal 0.0625
    end

    it "converts to weeks" do
      weeks = subject.to_weeks
      _(weeks).must_be_instance_of Duration::Weeks
      _(weeks.to_f).must_be_close_to 0.008928, 0.000001
    end

    it "converts to months" do
      months = subject.to_months
      _(months).must_be_instance_of Duration::Months
      _(months.to_f).must_be_close_to 0.002053, 0.000001
    end

    it "returns itself for to_minutes" do
      _((subject.to_minutes).object_id).must_equal subject.object_id
    end
  end

  describe "time calculations" do
    it "calculates ago from current time" do
      mins = Duration::Minutes.new(30)
      time_ago = mins.ago
      _(time_ago).must_be_instance_of Time
      _(Time.now - time_ago).must_be_close_to 1800.0, 1.0
    end

    it "calculates hence from current time" do
      mins = Duration::Minutes.new(30)
      time_hence = mins.hence
      _(time_hence).must_be_instance_of Time
      _(time_hence - Time.now).must_be_close_to 1800.0, 1.0
    end
  end
end
