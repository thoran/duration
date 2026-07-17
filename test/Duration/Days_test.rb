# test/duration/days_test.rb

require_relative '../test_helper'

describe Duration::Days do
  describe "initialization" do
    it "initializes with a float" do
      days = Duration::Days.new(7.5)
      _(days.instance_variable_get(:@days)).must_equal 7.5
      _(days.instance_variable_get(:@days)).must_be_kind_of Float
    end
  end

  describe "conversions" do
    before do
      @days = Duration::Days.new(2)
    end

    it "converts to milliseconds" do
      ms = @days.to_milliseconds
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_f).must_equal 172800000.0
    end

    it "converts to seconds" do
      secs = @days.to_seconds
      _(secs).must_be_instance_of Duration::Seconds
      _(secs.to_f).must_equal 172800.0
    end

    it "converts to minutes" do
      mins = @days.to_minutes
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.to_f).must_equal 2880.0
    end

    it "converts to hours" do
      hours = @days.to_hours
      _(hours).must_be_instance_of Duration::Hours
      _(hours.to_f).must_equal 48.0
    end

    it "converts to weeks" do
      weeks = @days.to_weeks
      _(weeks).must_be_instance_of Duration::Weeks
      _(weeks.to_f).must_be_close_to 0.2857, 0.001
    end

    it "converts to months" do
      months = @days.to_months
      _(months).must_be_instance_of Duration::Months
      _(months.to_f).must_be_close_to 0.065710, 0.00001
    end

    it "returns itself for to_days" do
      _((@days.to_days).object_id).must_equal @days.object_id
    end
  end

  describe "time calculations" do
    it "calculates ago from current time" do
      days = Duration::Days.new(1)
      time_ago = days.ago
      _(time_ago).must_be_instance_of Time
      _(Time.now - time_ago).must_be_close_to 86400.0, 1.0
    end

    it "calculates hence from current time" do
      days = Duration::Days.new(1)
      time_hence = days.hence
      _(time_hence).must_be_instance_of Time
      _(time_hence - Time.now).must_be_close_to 86400.0, 1.0
    end
  end
end
