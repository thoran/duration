# test/duration/common_test.rb

require_relative '../test_helper'
require_relative '../../lib/Duration/Numeric'

describe Duration::Common do
  describe "addition" do
    it "adds two durations of the same unit" do
      result = 5.minutes + 3.minutes
      _(result).must_be_instance_of Duration::Minutes
      _(result.to_i).must_equal 8
    end

    it "adds across units in the left operand's unit" do
      result = 5.minutes + 30.seconds
      _(result).must_be_instance_of Duration::Minutes
      _(result.to_f).must_equal 5.5
    end

    it "raises when combined with a non-duration" do
      _{5.minutes + 30}.must_raise TypeError
    end
  end

  describe "subtraction" do
    it "subtracts across units in the left operand's unit" do
      result = 5.minutes - 30.seconds
      _(result).must_be_instance_of Duration::Minutes
      _(result.to_f).must_equal 4.5
    end
  end

  describe "multiplication" do
    it "scales a duration by a number, keeping the unit" do
      result = 5.minutes * 3
      _(result).must_be_instance_of Duration::Minutes
      _(result.to_i).must_equal 15
    end

    it "raises upon a duration, there being no unit of time squared" do
      _{5.minutes * 3.minutes}.must_raise TypeError
    end

    it "raises upon a non-numeric" do
      _{5.minutes * "3"}.must_raise TypeError
    end
  end

  describe "division" do
    it "scales a duration by a number, keeping the unit" do
      result = 1.hour / 4
      _(result).must_be_instance_of Duration::Hours
      _(result.to_minutes.to_f).must_equal 15.0
    end

    it "divides exactly rather than as integers" do
      _(1.second / 3).must_equal Duration::Seconds.new(Rational(1, 3))
    end

    it "returns the dimensionless ratio of two durations" do
      _(1.hour / 30.minutes).must_equal 2
    end

    it "takes the ratio across units exactly" do
      _(1.second / 3.milliseconds).must_equal Rational(1000, 3)
    end

    it "raises upon a non-numeric" do
      _{5.minutes / "3"}.must_raise TypeError
    end
  end

  describe "comparison" do
    it "compares durations of different units exactly" do
      _(5.minutes).must_equal 300.seconds
      _(90.seconds).must_be :>, 1.minute
      _(1.hour).must_be :<, 2.hours
    end

    it "sorts a mixed collection" do
      sorted = [1.hour, 30.seconds, 5.minutes].sort
      _(sorted).must_equal [30.seconds, 5.minutes, 1.hour]
    end

    it "returns nil against a non-duration rather than raising" do
      _(5.minutes <=> 30).must_be_nil
    end

    it "is not equal to a non-duration" do
      _(5.minutes == 300).must_equal false
    end
  end

  describe "exactness" do
    it "converts without float drift" do
      # 1/6 of an hour is exactly 10 minutes; a float round-trip would not
      # land on 10.0.
      _((1.hour - 50.minutes).to_minutes.to_f).must_equal 10.0
    end
  end

  describe "#to_s" do
    it "names the quantity and the unit" do
      _(45.days.to_s).must_equal '45 days'
      _(500.nanoseconds.to_s).must_equal '500 nanoseconds'
    end

    it "drops the plural at one" do
      _(1.day.to_s).must_equal '1 day'
      _(1.month.to_s).must_equal '1 month'
    end

    it "keeps a float a float" do
      _(1.5.hours.to_s).must_equal '1.5 hours'
    end

    it "prints a whole Rational as a whole number" do
      _(Duration::Days.new(45r).to_s).must_equal '45 days'
    end

    it "keeps an exact ratio a ratio rather than expanding it" do
      # 45 days is exactly 45/7 weeks, and 6.428571428571429 is not.
      _(45.days.to_weeks.to_s).must_equal '45/7 weeks'
    end

    it "reads the unit from the class rather than repeating it" do
      _(90.minutes.to_hours.to_s).must_equal '3/2 hours'
    end
  end

  describe "#inspect" do
    it "names the class and the quantity as held" do
      _(45.days.inspect).must_equal 'Duration::Days(45)'
      _(1.5.hours.inspect).must_equal 'Duration::Hours(1.5)'
    end

    it "carries no address or ivar dump" do
      _(45.days.inspect).wont_match(/0x|@days/)
    end

    it "shows an exact quantity as the Rational it is, where to_s does not" do
      _(45.days.to_weeks.to_s).must_equal '45/7 weeks'
      _(45.days.to_weeks.inspect).must_equal 'Duration::Weeks((45/7))'
    end

    it "distinguishes a whole Rational from an Integer, where to_s cannot" do
      _(Duration::Days.new(45r).to_s).must_equal 45.days.to_s
      _(Duration::Days.new(45r).inspect).wont_equal 45.days.inspect
    end

    it "reaches a duration held inside a collection" do
      _({held_for: 45.days}.inspect).must_equal '{held_for: Duration::Days(45)}'
    end
  end
end
