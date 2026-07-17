# test/duration/seconds_test.rb

require_relative '../test_helper'

describe Duration::Seconds do
  describe "initialization" do
    it "initializes with a float" do
      secs = Duration::Seconds.new(60.5)
      _(secs.instance_variable_get(:@seconds)).must_equal 60.5
      _(secs.instance_variable_get(:@seconds)).must_be_kind_of Float
    end
  end

  describe "conversions" do
    subject do
      Duration::Seconds.new(90)
    end

    it "converts to milliseconds" do
      ms = subject.to_milliseconds
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_f).must_equal 90000.0
    end

    it "converts to minutes" do
      mins = subject.to_minutes
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.to_f).must_equal 1.5
    end

    it "converts to hours" do
      hours = subject.to_hours
      _(hours).must_be_instance_of Duration::Hours
      _(hours.to_f).must_equal 0.025
    end

    it "converts to days" do
      days = subject.to_days
      _(days).must_be_instance_of Duration::Days
      _(days.to_f).must_be_close_to 0.001041, 0.000001
    end

    it "converts to weeks" do
      weeks = subject.to_weeks
      _(weeks).must_be_instance_of Duration::Weeks
      _(weeks.to_f).must_be_close_to 0.0001488, 0.000001
    end

    it "converts to months" do
      months = subject.to_months
      _(months).must_be_instance_of Duration::Months
      _(months.to_f).must_be_close_to 3.422384e-05, 0.00000001
    end

    it "returns itself for to_seconds" do
      _((subject.to_seconds).object_id).must_equal subject.object_id
    end
  end

  describe "time calculations" do
    it "calculates ago from current time" do
      secs = Duration::Seconds.new(30)
      time_ago = secs.ago
      _(time_ago).must_be_instance_of Time
      _(Time.now - time_ago).must_be_close_to 30.0, 1.0
    end

    it "calculates hence from current time" do
      secs = Duration::Seconds.new(30)
      time_hence = secs.hence
      _(time_hence).must_be_instance_of Time
      _(time_hence - Time.now).must_be_close_to 30.0, 1.0
    end
  end
end
