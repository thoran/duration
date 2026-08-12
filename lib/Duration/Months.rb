# Duration/Months.rb
# Duration::Months

require_relative '../duration'

module Duration
  # A month is not a fixed quantity: its length depends on the calendar. The
  # conversions below use the Gregorian mean month (2629746 seconds), so they
  # are honest only as a statistical average, never as calendar-correct
  # arithmetic. For that, reach for a calendar-anchored type such as month.rb.
  #
  # ago and hence (via Relative) inherit the same caveat: they displace by the
  # mean month rather than an actual calendar month, so they are approximate,
  # not calendar-correct. Months is slated for removal in 0.5.0.
  class Months
    include Common
    include Relative

    def to_nanoseconds
      to_weeks.to_nanoseconds
    end

    def to_microseconds
      to_weeks.to_microseconds
    end

    def to_milliseconds
      to_weeks.to_milliseconds
    end

    def to_seconds
      to_weeks.to_seconds
    end

    def to_minutes
      to_weeks.to_minutes
    end

    def to_hours
      to_weeks.to_hours
    end

    def to_days
      to_weeks.to_days
    end

    def to_weeks
      # A month is the Gregorian mean: 2629746 seconds against 604800 per week.
      Duration::Weeks.new(@months * 2629746 / 604800r)
    end

    def to_months
      self
    end

    def to_i
      @months.to_i
    end

    def to_f
      @months.to_f
    end

    private

    def initialize(months = nil)
      @months = months
    end

    def unit
      :months
    end
  end
end
