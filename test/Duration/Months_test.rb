# test/duration/months_test.rb

require_relative '../test_helper'

describe Duration::Months do
  describe "initialization" do
    it "initializes with a float" do
      months = Duration::Months.new(3.5)
      _(months.instance_variable_get(:@months)).must_equal 3.5
      _(months.instance_variable_get(:@months)).must_be_kind_of Float
    end
  end

  describe "conversions" do
    subject do
      Duration::Months.new(2)
    end

    it "converts to milliseconds" do
      ms = subject.to_milliseconds
      _(ms).must_be_instance_of Duration::Milliseconds
      _(ms.to_f).must_equal 5259492000.0
    end

    it "converts to seconds" do
      secs = subject.to_seconds
      _(secs).must_be_instance_of Duration::Seconds
      _(secs.to_f).must_equal 5259492.0
    end

    it "converts to minutes" do
      mins = subject.to_minutes
      _(mins).must_be_instance_of Duration::Minutes
      _(mins.to_f).must_be_close_to 87658.2, 0.1
    end

    it "converts to hours" do
      hours = subject.to_hours
      _(hours).must_be_instance_of Duration::Hours
      _(hours.to_f).must_be_close_to 1460.97, 0.01
    end

    it "converts to days" do
      days = subject.to_days
      _(days).must_be_instance_of Duration::Days
      _(days.to_f).must_be_close_to 60.87375, 0.01
    end

    it "converts to weeks" do
      weeks = subject.to_weeks
      _(weeks).must_be_instance_of Duration::Weeks
      _(weeks.to_f).must_be_close_to 8.69625, 0.01
    end

    it "returns itself for to_months" do
      _((subject.to_months).object_id).must_equal subject.object_id
    end
  end

  describe "time calculations" do
    # A month is a calendar operation, not a fixed displacement, so Months
    # deliberately omits ago/hence. See month.rb for calendar-anchored work.
    it "does not respond to ago" do
      _(Duration::Months.new(1)).wont_respond_to :ago
    end

    it "does not respond to hence" do
      _(Duration::Months.new(1)).wont_respond_to :hence
    end
  end
end
