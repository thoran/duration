# test/duration/numeric_test.rb

require_relative '../test_helper'
require_relative '../../lib/Duration/Numeric'

describe Duration::Numeric do
  describe "nanosecond extensions" do
    it "creates Nanoseconds from integer" do
      ns = 1000.nanoseconds
      _(ns).must_be_instance_of Duration::Nanoseconds
      _(ns.to_i).must_equal 1000
    end

    it "supports singular alias" do
      ns = 1.nanosecond
      _(ns).must_be_instance_of Duration::Nanoseconds
      _(ns.to_i).must_equal 1
    end
  end

  describe "microsecond extensions" do
    it "creates Microseconds from integer" do
      us = 1000.microseconds
      _(us).must_be_instance_of Duration::Microseconds
      _(us.to_i).must_equal 1000
    end

    it "supports singular alias" do
      us = 1.microsecond
      _(us).must_be_instance_of Duration::Microseconds
      _(us.to_i).must_equal 1
    end
  end

  describe "millisecond extensions" do
    it "creates Milliseconds from integer" do
      ms = 1000.milliseconds
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_i).must_equal 1000
    end

    it "supports singular alias" do
      ms = 1.millisecond
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_i).must_equal 1
    end
  end

  describe "second extensions" do
    it "creates Seconds from integer" do
      secs = 60.seconds
      _(secs).must_be_instance_of Duration::Seconds
      _(secs.to_i).must_equal 60
    end

    it "supports singular alias" do
      sec = 1.second
      _(sec).must_be_instance_of Duration::Seconds
      _(sec.to_i).must_equal 1
    end
  end

  describe "minute extensions" do
    it "creates Minutes from integer" do
      mins = 30.minutes
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.to_i).must_equal 30
    end

    it "supports singular alias" do
      min = 1.minute
      _(min).must_be_instance_of Duration::Minutes
      _(min.to_i).must_equal 1
    end
  end

  describe "hour extensions" do
    it "creates Hours from integer" do
      hours = 24.hours
      _(hours).must_be_instance_of Duration::Hours
      _(hours.to_i).must_equal 24
    end

    it "supports singular alias" do
      hour = 1.hour
      _(hour).must_be_instance_of Duration::Hours
      _(hour.to_i).must_equal 1
    end
  end

  describe "day extensions" do
    it "creates Days from integer" do
      days = 7.days
      _(days).must_be_instance_of Duration::Days
      _(days.to_i).must_equal 7
    end

    it "supports singular alias" do
      day = 1.day
      _(day).must_be_instance_of Duration::Days
      _(day.to_i).must_equal 1
    end
  end

  describe "week extensions" do
    it "creates Weeks from integer" do
      weeks = 4.weeks
      _(weeks).must_be_instance_of Duration::Weeks
      _(weeks.to_i).must_equal 4
    end

    it "supports singular alias" do
      week = 1.week
      _(week).must_be_instance_of Duration::Weeks
      _(week.to_i).must_equal 1
    end
  end

  describe "month extensions" do
    it "creates Months from integer" do
      months = 6.months
      _(months).must_be_instance_of Duration::Months
      _(months.to_i).must_equal 6
    end

    it "supports singular alias" do
      month = 1.month
      _(month).must_be_instance_of Duration::Months
      _(month.to_i).must_equal 1
    end
  end

  describe "float support" do
    it "works with float values" do
      mins = 1.5.minutes
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.to_f).must_equal 1.5
    end
  end
end
