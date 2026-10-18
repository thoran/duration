# Duration/Weeks.rb
# Duration::Weeks

require_relative '../duration'

module Duration
  class Weeks
    include Common
    include Relative
    extend ISO8601

    def to_nanoseconds
      to_days.to_nanoseconds
    end

    def to_microseconds
      to_days.to_microseconds
    end

    def to_milliseconds
      to_days.to_milliseconds
    end

    def to_seconds
      to_days.to_seconds
    end

    def to_minutes
      to_days.to_minutes
    end

    def to_hours
      to_days.to_hours
    end

    def to_days
      Duration::Days.new(@weeks * 7)
    end

    def to_weeks
      self
    end

    def to_months
      # A month is the Gregorian mean: 2629746 seconds against 604800 per week.
      Duration::Months.new(@weeks * 604800 / 2629746r)
    end

    def to_i
      @weeks.to_i
    end

    def to_f
      @weeks.to_f
    end

    private

    def initialize(weeks = nil)
      @weeks = weeks
    end

    def unit
      :weeks
    end
  end
end
