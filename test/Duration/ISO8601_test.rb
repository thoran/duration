# test/duration/iso8601_test.rb

require_relative '../test_helper'

describe Duration::ISO8601::Reader do
  describe ".from_iso8601" do
    it "is upon every unit" do
      units = Duration.constants.map{|name| Duration.const_get(name)}.select{|constant| constant.is_a?(Class)}
      _(units.size).must_equal 9
      _(units.all?{|unit| unit.respond_to?(:from_iso8601)}).must_equal true
    end

    it "reads into seconds as an Integer" do
      secs = Duration::Seconds.from_iso8601('PT1H2M3S')
      _(secs).must_be_instance_of Duration::Seconds
      _(secs.instance_variable_get(:@seconds)).must_equal 3723
      _(secs.instance_variable_get(:@seconds)).must_be_kind_of Integer
    end

    it "reads into minutes exactly, as a Rational where the seconds do not divide evenly" do
      mins = Duration::Minutes.from_iso8601('PT1H2M3S')
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.instance_variable_get(:@minutes)).must_equal Rational(1241, 20)
    end

    it "reads into each unit in that unit's own terms" do
      _(Duration::Hours.from_iso8601('P1DT2H').instance_variable_get(:@hours)).must_equal 26
      _(Duration::Days.from_iso8601('P2W').instance_variable_get(:@days)).must_equal 14
      _(Duration::Milliseconds.from_iso8601('PT1S').instance_variable_get(:@milliseconds)).must_equal 1000
      _(Duration::Nanoseconds.from_iso8601('PT1S').instance_variable_get(:@nanoseconds)).must_equal 1_000_000_000
    end

    it "sums only the components written, so an absent one makes nothing inexact" do
      weeks = Duration::Weeks.from_iso8601('P1W')
      _(weeks.instance_variable_get(:@weeks)).must_equal 1
      _(weeks.instance_variable_get(:@weeks)).must_be_kind_of Integer
    end

    it "reads any subset of the components" do
      _(Duration::Seconds.from_iso8601('PT45S').to_i).must_equal 45
      _(Duration::Seconds.from_iso8601('PT1H').to_i).must_equal 3600
      _(Duration::Seconds.from_iso8601('P1DT2H').to_i).must_equal 93600
      _(Duration::Seconds.from_iso8601('P1D').to_i).must_equal 86400
    end

    it "reads M after the T as minutes" do
      _(Duration::Minutes.from_iso8601('PT1M').to_i).must_equal 1
      _(Duration::Seconds.from_iso8601('P1DT1M').to_i).must_equal 86460
    end

    it "reads P0D as zero" do
      _(Duration::Seconds.from_iso8601('P0D').to_i).must_equal 0
      _(Duration::Seconds.from_iso8601('PT0S').to_i).must_equal 0
      _(Duration::Hours.from_iso8601('P0D').to_i).must_equal 0
    end

    it "counts a week as seven days" do
      _(Duration::Seconds.from_iso8601('P1W').to_i).must_equal 604800
      _(Duration::Seconds.from_iso8601('P2W3DT4S').to_i).must_equal 1468804
    end

    it "reads into months by the mean month, as the conversions do" do
      _(Duration::Months.from_iso8601('P1D')).must_equal Duration::Days.new(1).to_months
    end

    it "reads a fraction upon the last component" do
      _(Duration::Seconds.from_iso8601('PT1.5S').instance_variable_get(:@seconds)).must_equal Rational(3, 2)
      _(Duration::Seconds.from_iso8601('PT1,5S').instance_variable_get(:@seconds)).must_equal Rational(3, 2)
      _(Duration::Minutes.from_iso8601('PT1.5H')).must_equal Duration::Minutes.new(90)
      _(Duration::Days.from_iso8601('P0.125D').instance_variable_get(:@days)).must_equal Rational(1, 8)
    end

    it "reads months into Months, as the mean month" do
      _(Duration::Months.from_iso8601('P1M').instance_variable_get(:@months)).must_equal 1
      _(Duration::Months.from_iso8601('P1M15D')).must_equal Duration::Months.new(1) + Duration::Days.new(15)
      _(Duration::Months.from_iso8601('P1M2W3DT4H')).must_equal Duration::Months.new(1) + Duration::Weeks.new(2) + Duration::Days.new(3) + Duration::Hours.new(4)
    end

    it "refuses months into any other unit" do
      %w{Seconds Days Weeks}.product(%w{P1M P1MT1H}).each do |unit, string|
        error = _{Duration.const_get(unit).from_iso8601(string)}.must_raise ArgumentError
        _(error.message).must_match(/only Duration::Months reads/)
      end
    end

    it "refuses years, which have no fixed length, Months included" do
      [Duration::Seconds, Duration::Months].product(%w{P1Y P1Y2M3D P1.5Y}).each do |unit, string|
        error = _{unit.from_iso8601(string)}.must_raise ArgumentError
        _(error.message).must_match(/has years/)
      end
    end

    it "refuses what is not an ISO 8601 duration" do
      ['', 'P', 'PT', 'P1DT', '1H', 'pt1h', ' PT1H', 'PT1H ', 'PT1S1M', 'PT1.5H30M', 'PT.5S', 'PT1.S', '-P1D', nil].each do |string|
        error = _{Duration::Seconds.from_iso8601(string)}.must_raise ArgumentError
        _(error.message).must_match(/not an ISO 8601 duration/)
      end
    end

    it "leaves the constructor as it was" do
      _(Duration::Seconds.new('PT1H').instance_variable_get(:@seconds)).must_equal 'PT1H'
    end

    it "keeps its helper private" do
      _(Duration::Seconds.respond_to?(:iso8601_components)).must_equal false
    end
  end
end

describe Duration::ISO8601::Writer do
  describe "#to_iso8601" do
    it "is upon every unit" do
      units = Duration.constants.map{|name| Duration.const_get(name)}.select{|constant| constant.is_a?(Class)}
      _(units.all?{|unit| unit.new(1).respond_to?(:to_iso8601)}).must_equal true
    end

    it "writes each unit in its own designator, as it is held" do
      _(Duration::Seconds.new(3723).to_iso8601).must_equal 'PT3723S'
      _(Duration::Minutes.new(90).to_iso8601).must_equal 'PT90M'
      _(Duration::Hours.new(25).to_iso8601).must_equal 'PT25H'
      _(Duration::Days.new(14).to_iso8601).must_equal 'P14D'
      _(Duration::Weeks.new(2).to_iso8601).must_equal 'P2W'
      _(Duration::Months.new(1).to_iso8601).must_equal 'P1M'
    end

    it "writes zero in its own designator" do
      _(Duration::Seconds.new(0).to_iso8601).must_equal 'PT0S'
      _(Duration::Weeks.new(0).to_iso8601).must_equal 'P0W'
    end

    it "writes a unit smaller than a second in seconds" do
      _(Duration::Milliseconds.new(1500).to_iso8601).must_equal 'PT1.5S'
      _(Duration::Nanoseconds.new(1).to_iso8601).must_equal 'PT0.000000001S'
    end

    it "writes a fraction exactly where it has a finite decimal" do
      _(Duration::Minutes.new(Rational(3, 2)).to_iso8601).must_equal 'PT1.5M'
      _(Duration::Days.new(Rational(1, 8)).to_iso8601).must_equal 'P0.125D'
    end

    it "takes a Float as it prints" do
      _(Duration::Hours.new(1.5).to_iso8601).must_equal 'PT1.5H'
      _(Duration::Hours.new(0.1).to_iso8601).must_equal 'PT0.1H'
      _(Duration::Seconds.new(3600.0).to_iso8601).must_equal 'PT3600S'
    end

    it "refuses a fraction with no finite decimal" do
      error = _{Duration::Minutes.new(Rational(1, 7)).to_iso8601}.must_raise ArgumentError
      _(error.message).must_match(/no exact decimal/)
    end

    it "rounds to the fraction digits given, and pads to them" do
      _(Duration::Minutes.new(Rational(1, 7)).to_iso8601(3)).must_equal 'PT0.143M'
      _(Duration::Minutes.new(90).to_iso8601(2)).must_equal 'PT90.00M'
      _(Duration::Seconds.new(1.15).to_iso8601(1)).must_equal 'PT1.2S'
    end

    it "refuses a negative duration" do
      [Duration::Seconds.new(-1), Duration::Milliseconds.new(-1)].each do |duration|
        error = _{duration.to_iso8601}.must_raise ArgumentError
        _(error.message).must_match(/negative/)
      end
    end

    it "refuses what is not finite" do
      error = _{Duration::Seconds.new(Float::INFINITY).to_iso8601}.must_raise ArgumentError
      _(error.message).must_match(/not finite/)
    end

    it "keeps its helpers private" do
      %i{iso8601_validate iso8601_units iso8601_parts iso8601_cascade iso8601_exact iso8601_number iso8601_places iso8601_decimal}.each do |helper|
        _(Duration::Seconds.new(1).respond_to?(helper)).must_equal false
      end
    end

    describe "split: true" do
      it "splits into days, hours, minutes and seconds" do
        _(Duration::Seconds.new(3723).to_iso8601(split: true)).must_equal 'PT1H2M3S'
        _(Duration::Hours.new(25).to_iso8601(split: true)).must_equal 'P1DT1H'
      end

      it "leaves out what is zero" do
        _(Duration::Minutes.new(90).to_iso8601(split: true)).must_equal 'PT1H30M'
        _(Duration::Days.new(1).to_iso8601(split: true)).must_equal 'P1D'
        _(Duration::Seconds.new(86401).to_iso8601(split: true)).must_equal 'P1DT1S'
      end

      it "writes zero as PT0S" do
        _(Duration::Seconds.new(0).to_iso8601(split: true)).must_equal 'PT0S'
        _(Duration::Weeks.new(0).to_iso8601(split: true)).must_equal 'PT0S'
      end

      it "writes weeks as days, and months as the mean month" do
        _(Duration::Weeks.new(2).to_iso8601(split: true)).must_equal 'P14D'
        _(Duration::Months.new(1).to_iso8601(split: true)).must_equal 'P30DT10H29M6S'
      end

      it "writes what remains of a second as a fraction upon the seconds" do
        _(Duration::Milliseconds.new(1500).to_iso8601(split: true)).must_equal 'PT1.5S'
        _(Duration::Minutes.new(Rational(3, 2)).to_iso8601(split: true)).must_equal 'PT1M30S'
      end

      it "takes a Float as it prints" do
        _(Duration::Hours.new(1.5).to_iso8601(split: true)).must_equal 'PT1H30M'
        _(Duration::Hours.new(0.1).to_iso8601(split: true)).must_equal 'PT6M'
      end

      it "rounds the last component to the fraction digits given" do
        _(Duration::Minutes.new(Rational(1, 7)).to_iso8601(3, split: true)).must_equal 'PT8.571S'
        _(Duration::Seconds.new(Rational(3, 2)).to_iso8601(3, split: true)).must_equal 'PT1.500S'
      end
    end

    describe "split: units" do
      it "splits into the units named" do
        _(Duration::Minutes.new(90.5).to_iso8601(split: %i{hours minutes})).must_equal 'PT1H30.5M'
        _(Duration::Days.new(45).to_iso8601(split: %i{weeks days})).must_equal 'P6W3D'
        _(Duration::Seconds.new(2629746 + 86400).to_iso8601(split: %i{months days hours minutes seconds})).must_equal 'P1M1D'
      end

      it "refuses units out of order, unknown or absent" do
        [%i{seconds minutes}, %i{fortnights}, [], %i{hours hours}].each do |split|
          error = _{Duration::Seconds.new(1).to_iso8601(split: split)}.must_raise ArgumentError
          _(error.message).must_match(/largest first/)
        end
      end
    end

    it "is read back as the duration written, into the same unit" do
      durations = [
        Duration::Seconds.new(3723), Duration::Minutes.new(Rational(3, 2)), Duration::Hours.new(25),
        Duration::Days.new(9), Duration::Weeks.new(3), Duration::Months.new(2),
        Duration::Milliseconds.new(1500), Duration::Seconds.new(0),
      ]
      [{}, {split: true}, {split: %i{weeks days hours minutes seconds}}].product(durations).each do |options, duration|
        _(duration.class.from_iso8601(duration.to_iso8601(**options))).must_equal duration
      end
    end
  end
end

describe Duration::ISO8601 do
  it "puts each method upon its own side only" do
    _(Duration::Seconds.respond_to?(:to_iso8601)).must_equal false
    _(Duration::Seconds.new(1).respond_to?(:from_iso8601)).must_equal false
  end

  it "is a namespace, not a mixin" do
    _(Duration::ISO8601.instance_methods).must_be_empty
  end
end
