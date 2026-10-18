# test/duration-classes_test.rb

require_relative './test_helper'
require_relative '../lib/duration-classes'

describe 'duration-classes' do
  it "names the unit classes at the top level" do
    _(Days.new(45).to_s).must_equal '45 days'
  end

  it "names every class Duration holds, and only those" do
    units = Duration.constants.select{|name| Duration.const_get(name).is_a?(Class)}
    _(units.all?{|name| Object.const_defined?(name, false)}).must_equal true
  end

  it "does not rename the classes" do
    _(Days.name).must_equal 'Duration::Days'
  end

  it "leaves Common, Relative, ISO8601 and VERSION where they are" do
    _([:Common, :Relative, :ISO8601, :VERSION].none?{|name| Object.const_defined?(name, false)}).must_equal true
  end

  # These two want a process of its own: each turns upon what the top level held
  # before the require, and this one has already required it.
  describe "meeting a name the program had given" do
    def ruby(source)
      lib = File.expand_path('../lib', __dir__)
      IO.popen(['ruby', "-I#{lib}", '-e', source], err: [:child, :out]){|io| io.read}.strip
    end

    it "takes the name and says so, where the program named it first" do
      output = ruby('class Days; def self.mine; end; end; require "duration-classes"; ' \
        'print Days.respond_to?(:mine)')
      _(output).must_match(/already initialized constant Days/)
      _(output).must_match(/false\z/)
    end

    it "is reopened rather than replaced, where the program names it after" do
      _(ruby('require "duration-classes"; class Days; def self.mine; end; end; ' \
        'print [Days.name, Days.respond_to?(:mine)].inspect')) \
        .must_equal('["Duration::Days", true]')
    end
  end
end
