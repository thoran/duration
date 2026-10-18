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

    it "refuses years and months, which have no fixed length, Months included" do
      [Duration::Seconds, Duration::Months].product(%w{P1Y P1M P1Y2M3D P1MT1H}).each do |unit, string|
        error = _{unit.from_iso8601(string)}.must_raise ArgumentError
        _(error.message).must_match(/years or months/)
      end
    end

    it "refuses what is not an ISO 8601 duration" do
      ['', 'P', 'PT', 'P1DT', '1H', 'pt1h', ' PT1H', 'PT1H ', 'PT1S1M', 'PT1.5S', '-P1D', nil].each do |string|
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

    it "writes hours, minutes and seconds" do
      _(Duration::Seconds.new(3723).to_iso8601).must_equal 'PT1H2M3S'
    end

    it "leaves out what is zero" do
      _(Duration::Minutes.new(90).to_iso8601).must_equal 'PT1H30M'
      _(Duration::Days.new(1).to_iso8601).must_equal 'P1D'
      _(Duration::Seconds.new(86401).to_iso8601).must_equal 'P1DT1S'
      _(Duration::Hours.new(25).to_iso8601).must_equal 'P1DT1H'
    end

    it "writes zero as PT0S" do
      _(Duration::Seconds.new(0).to_iso8601).must_equal 'PT0S'
      _(Duration::Weeks.new(0).to_iso8601).must_equal 'PT0S'
    end

    it "writes weeks as days" do
      _(Duration::Weeks.new(2).to_iso8601).must_equal 'P14D'
    end

    it "writes from any unit by its conversions" do
      _(Duration::Milliseconds.new(1000).to_iso8601).must_equal 'PT1S'
      _(Duration::Seconds.new(3600.0).to_iso8601).must_equal 'PT1H'
      _(Duration::Minutes.new(Rational(3, 2)).to_iso8601).must_equal 'PT1M30S'
    end

    it "writes months as the mean month" do
      _(Duration::Months.new(1).to_iso8601).must_equal 'P30DT10H29M6S'
    end

    it "refuses a part second" do
      [Duration::Milliseconds.new(1500), Duration::Minutes.new(Rational(1, 7)), Duration::Seconds.new(0.5)].each do |duration|
        error = _{duration.to_iso8601}.must_raise ArgumentError
        _(error.message).must_match(/not a whole number of seconds/)
      end
    end

    it "refuses a negative duration" do
      error = _{Duration::Seconds.new(-1).to_iso8601}.must_raise ArgumentError
      _(error.message).must_match(/negative/)
    end

    it "is read back as the duration written" do
      [Duration::Seconds.new(3723), Duration::Days.new(9), Duration::Weeks.new(3), Duration::Months.new(2), Duration::Seconds.new(0)].each do |duration|
        _(duration.class.from_iso8601(duration.to_iso8601)).must_equal duration
      end
    end

    it "keeps its helpers private" do
      _(Duration::Seconds.new(1).respond_to?(:iso8601_quantities)).must_equal false
      _(Duration::Seconds.new(1).respond_to?(:iso8601_seconds)).must_equal false
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
