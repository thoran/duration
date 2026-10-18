# test/loading_test.rb

require_relative './test_helper'

# Each of these wants a process of its own. Within this one the test helper has already loaded the lot, so nothing here could tell a unit which was declared from a unit which was read.

describe 'loading' do
  def ruby(source, *flags)
    lib = File.expand_path('../lib', __dir__)
    IO.popen(['ruby', *flags, "-I#{lib}", '-e', source], err: [:child, :out]){|io| io.read}.strip
  end

  it "converts when a single unit file is required alone" do
    _(ruby('require "Duration/Seconds"; print Duration::Seconds.new(90).to_minutes.to_f')) \
      .must_equal('1.5')
  end

  it "does not read a unit which is never named" do
    _(ruby('require "duration.rb"; Duration::Seconds; print $LOADED_FEATURES.grep(/Months/).size')) \
      .must_equal('0')
  end

  it "reads a unit as soon as it is named" do
    _(ruby('require "duration.rb"; Duration::Months; print $LOADED_FEATURES.grep(/Months/).size')) \
      .must_equal('1')
  end

  it "reads only the units a string names" do
    _(ruby('require "duration.rb"; Duration::Seconds.from_iso8601("PT1H"); print $LOADED_FEATURES.grep(/Months|Weeks|Days/).size')) \
      .must_equal('0')
  end

  it "loads without warning under -w, no unit requiring another" do
    _(ruby('require "duration.rb"; Duration::Months.new(1).to_nanoseconds; print "ok"', '-w')) \
      .must_equal('ok')
  end
end
