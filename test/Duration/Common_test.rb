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

  describe "#divmod" do
    it "gives the whole number of times and the duration left over" do
      _(3723.seconds.divmod(1.hour)).must_equal [1, Duration::Seconds.new(123)]
    end

    it "gives a whole number as the quotient" do
      _(45.days.divmod(1.week).first).must_be_kind_of Integer
      _(90.5.minutes.divmod(1.hour).first).must_be_kind_of Integer
    end

    it "keeps the remainder in the left operand's unit" do
      _(45.days.divmod(1.week).last).must_be_instance_of Duration::Days
      _(1.hour.divmod(25.minutes).last).must_equal Duration::Hours.new(1/6r)
    end

    it "floors the quotient as Numeric#divmod does" do
      _((-3723).seconds.divmod(1.hour)).must_equal [-2, Duration::Seconds.new(3477)]
      _(3723.seconds.divmod(-1.hour)).must_equal [-2, Duration::Seconds.new(-3477)]
    end

    it "raises upon a zero duration" do
      _{3723.seconds.divmod(0.hours)}.must_raise ZeroDivisionError
    end

    it "raises upon a non-duration" do
      _{3723.seconds.divmod(60)}.must_raise TypeError
    end
  end

  describe "#%" do
    it "gives the duration left over" do
      _(3723.seconds % 1.hour).must_equal Duration::Seconds.new(123)
      _(3723.seconds % 1.hour).must_be_instance_of Duration::Seconds
    end

    it "raises upon a non-duration" do
      _{3723.seconds % 60}.must_raise TypeError
    end
  end

  describe "#split" do
    it "splits into the units given, largest first" do
      _(3723.seconds.split(Duration::Hours, Duration::Minutes, Duration::Seconds)).must_equal [Duration::Hours.new(1), Duration::Minutes.new(2), Duration::Seconds.new(3)]
      _(45.days.split(Duration::Weeks, Duration::Days)).must_equal [Duration::Weeks.new(6), Duration::Days.new(3)]
    end

    it "gives each part in its own unit" do
      parts = 3723.seconds.split(Duration::Hours, Duration::Minutes, Duration::Seconds)
      _(parts.map(&:class)).must_equal [Duration::Hours, Duration::Minutes, Duration::Seconds]
    end

    it "gives what remains to the last unit, fraction and all" do
      _(90.5.minutes.split(Duration::Hours, Duration::Minutes)).must_equal [Duration::Hours.new(1), Duration::Minutes.new(30.5)]
      _(90.seconds.split(Duration::Minutes)).must_equal [Duration::Minutes.new(3/2r)]
    end

    it "sums back to the whole exactly" do
      [3723.seconds, 45.days, 1.month, Duration::Minutes.new(1/7r), 1500.milliseconds].each do |duration|
        _(duration.split(Duration::Days, Duration::Hours, Duration::Minutes, Duration::Seconds).sum(Duration::Seconds.new(0))).must_equal duration
      end
    end

    it "gives zero to a unit the duration does not reach" do
      _(3.seconds.split(Duration::Hours, Duration::Seconds)).must_equal [Duration::Hours.new(0), Duration::Seconds.new(3)]
    end

    it "takes months only when they are named" do
      _(1.month.split(Duration::Days, Duration::Seconds)).must_equal [Duration::Days.new(30), Duration::Seconds.new(37746)]
      _(45.days.split(Duration::Months, Duration::Days).first).must_equal Duration::Months.new(1)
    end

    it "splits a negative duration into parts all of its own sign" do
      _((-3723).seconds.split(Duration::Hours, Duration::Minutes, Duration::Seconds)).must_equal [Duration::Hours.new(-1), Duration::Minutes.new(-2), Duration::Seconds.new(-3)]
    end

    it "raises upon no units" do
      _{3723.seconds.split}.must_raise ArgumentError
    end

    it "raises upon units out of order" do
      _{3723.seconds.split(Duration::Minutes, Duration::Hours)}.must_raise ArgumentError
      _{3723.seconds.split(Duration::Minutes, Duration::Minutes)}.must_raise ArgumentError
    end

    it "raises upon anything but a unit class" do
      _{3723.seconds.split(:hours, :minutes)}.must_raise ArgumentError
      _{3723.seconds.split(String)}.must_raise ArgumentError
    end
  end

  describe "#floor" do
    it "floors to a whole multiple of the duration given" do
      _(97.minutes.floor(15.minutes)).must_equal Duration::Minutes.new(90)
    end

    it "floors to a whole number of its own unit when given none" do
      _(Duration::Hours.new(3/2r).floor).must_equal Duration::Hours.new(1)
    end

    it "keeps the left operand's unit" do
      _(5400.seconds.floor(1.hour)).must_be_instance_of Duration::Seconds
      _(5400.seconds.floor(1.hour)).must_equal Duration::Seconds.new(3600)
    end

    it "stays exact" do
      _(1.hour.floor(7.minutes).inspect).must_equal 'Duration::Hours((14/15))'
    end

    it "floors a negative duration downward" do
      _((-97).minutes.floor(15.minutes)).must_equal Duration::Minutes.new(-105)
    end

    it "raises upon a zero duration" do
      _{97.minutes.floor(0.minutes)}.must_raise ZeroDivisionError
    end

    it "raises upon a non-duration" do
      _{97.minutes.floor(15)}.must_raise TypeError
    end
  end

  describe "#ceil" do
    it "ceils to a whole multiple of the duration given" do
      _(97.minutes.ceil(15.minutes)).must_equal Duration::Minutes.new(105)
    end

    it "ceils to a whole number of its own unit when given none" do
      _(Duration::Hours.new(3/2r).ceil).must_equal Duration::Hours.new(2)
    end

    it "ceils a negative duration upward" do
      _((-97).minutes.ceil(15.minutes)).must_equal Duration::Minutes.new(-90)
    end

    it "raises upon a non-duration" do
      _{97.minutes.ceil(15)}.must_raise TypeError
    end
  end

  describe "#round" do
    it "rounds to the nearest multiple of the duration given" do
      _(97.minutes.round(15.minutes)).must_equal Duration::Minutes.new(90)
      _(98.minutes.round(15.minutes)).must_equal Duration::Minutes.new(105)
    end

    it "rounds to a whole number of its own unit when given none" do
      _(Duration::Hours.new(5/2r).round).must_equal Duration::Hours.new(3)
    end

    it "rounds a tie away from zero, as Numeric#round does" do
      _(45.minutes.round(30.minutes)).must_equal Duration::Minutes.new(60)
      _((-45).minutes.round(30.minutes)).must_equal Duration::Minutes.new(-60)
    end

    it "decides a tie by half:" do
      _(45.minutes.round(30.minutes, half: :down)).must_equal Duration::Minutes.new(30)
      _(Duration::Hours.new(5/2r).round(half: :even)).must_equal Duration::Hours.new(2)
    end

    it "counts in steps, so half: :even goes to an even number of them" do
      _(15.minutes.round(30.minutes, half: :even)).must_equal Duration::Minutes.new(0)
      _(45.minutes.round(30.minutes, half: :even)).must_equal Duration::Minutes.new(60)
      _(75.minutes.round(30.minutes, half: :even)).must_equal Duration::Minutes.new(60)
    end

    it "rounds a Float to a whole number of steps" do
      _(97.5.minutes.round(15.minutes)).must_equal Duration::Minutes.new(105)
    end

    it "raises upon a non-duration" do
      _{97.minutes.round(15)}.must_raise TypeError
    end
  end

  describe "#truncate" do
    it "truncates to a whole multiple of the duration given" do
      _(97.minutes.truncate(15.minutes)).must_equal Duration::Minutes.new(90)
    end

    it "truncates to a whole number of its own unit when given none" do
      _(Duration::Hours.new(-3/2r).truncate).must_equal Duration::Hours.new(-1)
    end

    it "truncates a negative duration toward zero, where floor goes downward" do
      _((-97).minutes.truncate(15.minutes)).must_equal Duration::Minutes.new(-90)
    end

    it "raises upon a non-duration" do
      _{97.minutes.truncate(15)}.must_raise TypeError
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
