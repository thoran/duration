# test/duration/version_test.rb

require_relative '../test_helper'

# Note that VERSION.rb is the one file duration.rb requires rather than autoloaded, because an autoloaded file goes unread until its constant is named and nothing else here names this one.

describe Duration do
  describe "VERSION" do
    it "is a string" do
      _(Duration::VERSION).must_be_instance_of String
    end

    it "is three numbers separated by dots" do
      _(Duration::VERSION).must_match(/\A\d+\.\d+\.\d+\z/)
    end

    it "matches the newest entry in the CHANGELOG" do
      changelog = File.read(File.expand_path('../../CHANGELOG', __dir__))
      _(changelog[/^(\d+\.\d+\.\d+):/, 1]).must_equal Duration::VERSION
    end
  end
end
