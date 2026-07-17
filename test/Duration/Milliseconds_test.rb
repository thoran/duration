# test/duration/milliseconds_test.rb

require_relative '../test_helper'

describe Duration::Milliseconds do
  describe "initialization" do
    it "initializes with an float" do
      ms = Duration::Milliseconds.new(1500.5)
      _(ms.instance_variable_get(:@milliseconds)).must_equal 1500.5
      _(ms.instance_variable_get(:@milliseconds)).must_be_kind_of Float
    end
  end

  describe "conversions" do
    subject do
      Duration::Milliseconds.new(5000)
    end

    it "converts to seconds" do
      seconds = subject.to_seconds
      _(seconds).must_be_instance_of Duration::Seconds
      _(seconds.to_f).must_equal 5.0
    end

    it "converts to minutes" do
      minutes = subject.to_minutes
      _(minutes).must_be_instance_of Duration::Minutes
      _(minutes.to_f).must_be_close_to 0.0833, 0.0001
    end

    it "converts to hours" do
      hours = subject.to_hours
      _(hours).must_be_instance_of Duration::Hours
      _(hours.to_f).must_be_close_to 0.00138, 0.00001
    end

    it "converts to days" do
      days = subject.to_days
      _(days).must_be_instance_of Duration::Days
      _(days.to_f).must_be_close_to 5.787037e-5, 0.000001
    end

    it "converts to weeks" do
      weeks = subject.to_weeks
      _(weeks).must_be_instance_of Duration::Weeks
      _(weeks.to_f).must_be_close_to 8.267195e-6, 0.000001
    end

    it "converts to months" do
      months = subject.to_months
      _(months).must_be_instance_of Duration::Months
      _(months.to_f).must_be_close_to 1.901337e-6, 0.000001
    end

    it "returns itself for to_milliseconds" do
      _((subject.to_milliseconds).object_id).must_equal subject.object_id
    end
  end

  describe "time calculations" do
    it "calculates ago from current time" do
      ms = Duration::Milliseconds.new(1000)
      time_ago = ms.ago
      _(time_ago).must_be_instance_of Time
      _(time_ago).must_be :<, Time.now
    end

    it "calculates hence from current time" do
      ms = Duration::Milliseconds.new(1000)
      time_hence = ms.hence
      _(time_hence).must_be_instance_of Time
      _(time_hence).must_be :>, Time.now
    end
  end
end
