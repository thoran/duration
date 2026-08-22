# test/duration-numeric_test.rb

require_relative './test_helper'
require_relative '../lib/duration-numeric'

# Duration::Numeric is covered by test/Duration/Numeric_test.rb, which requires
# the module directly.  This covers the file which requires it for you, that
# being a path nothing else takes.

describe 'duration-numeric' do
  it "gives the Numeric sugar" do
    _(5.minutes.to_s).must_equal '5 minutes'
  end

  it "brings the core with it" do
    _(Duration::Days.new(1).to_s).must_equal '1 day'
  end

  # A process of its own: this one has required duration-classes as well, which
  # names the units at the top level and cannot be undone within a process.
  it "names nothing at the top level" do
    lib = File.expand_path('../lib', __dir__)
    named = IO.popen(['ruby', "-I#{lib}", '-e',
      'require "duration-numeric"; ' \
      'print Duration.constants.select{|n| Duration.const_get(n).is_a?(Class)}.any?{|n| Object.const_defined?(n, false)}'],
      err: [:child, :out]){|io| io.read}.strip
    _(named).must_equal 'false'
  end
end
