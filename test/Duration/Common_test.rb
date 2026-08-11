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
end
