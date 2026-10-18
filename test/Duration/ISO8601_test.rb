# test/duration/iso8601_test.rb

require_relative '../test_helper'

describe Duration::ISO8601 do
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
