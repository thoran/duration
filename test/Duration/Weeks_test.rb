# test/duration/weeks_test.rb

require_relative '../test_helper'

describe Duration::Weeks do
  describe "initialization" do
    it "initializes with a float" do
      weeks = Duration::Weeks.new(2.5)
      _(weeks.instance_variable_get(:@weeks)).must_equal 2.5
      _(weeks.instance_variable_get(:@weeks)).must_be_kind_of Float
    end
  end

  describe "conversions" do
    subject do
      Duration::Weeks.new(2)
    end

    it "converts to milliseconds" do
      ms = subject.to_milliseconds
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_f).must_equal 1209600000.0
    end

    it "converts to seconds" do
      secs = subject.to_seconds
      _(secs).must_be_instance_of Duration::Seconds
      _(secs.to_f).must_equal 1209600.0
    end

    it "converts to minutes" do
      mins = subject.to_minutes
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.to_f).must_equal 20160.0
    end

    it "converts to hours" do
      hours = subject.to_hours
      _(hours).must_be_instance_of Duration::Hours
      _(hours.to_f).must_equal 336.0
    end

    it "converts to days" do
      days = subject.to_days
      _(days).must_be_instance_of Duration::Days
      _(days.to_f).must_equal 14.0
    end

    it "converts to months" do
      months = subject.to_months
      _(months).must_be_instance_of Duration::Months
      _(months.to_f).must_be_close_to 0.459968, 0.000001
    end

    it "returns itself for to_weeks" do
      _((subject.to_weeks).object_id).must_equal subject.object_id
    end
  end

  describe "time calculations" do
    it "calculates ago from current time" do
      weeks = Duration::Weeks.new(1)
      time_ago = weeks.ago
      _(time_ago).must_be_instance_of Time
      _(Time.now - time_ago).must_be_close_to 604800.0, 1.0
    end

    it "calculates hence from current time" do
      weeks = Duration::Weeks.new(1)
      time_hence = weeks.hence
      _(time_hence).must_be_instance_of Time
      _(time_hence - Time.now).must_be_close_to 604800.0, 1.0
    end
  end
end
