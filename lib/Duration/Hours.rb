# Duration/Hours.rb
# Duration::Hours

require_relative '../duration'

module Duration
  class Hours
    include Common
    include Relative
    extend ISO8601::Reader

    def to_nanoseconds
      to_minutes.to_nanoseconds
    end

    def to_microseconds
      to_minutes.to_microseconds
    end

    def to_milliseconds
      to_minutes.to_milliseconds
    end

    def to_seconds
      to_minutes.to_seconds
    end

    def to_minutes
      Duration::Minutes.new(@hours * 60)
    end

    def to_hours
      self
    end

    def to_days
      Duration::Days.new(@hours / 24r)
    end

    def to_weeks
      to_days.to_weeks
    end

    def to_months
      to_days.to_months
    end

    def to_i
      @hours.to_i
    end

    def to_f
      @hours.to_f
    end

    private

    def initialize(hours = nil)
      @hours = hours
    end

    def unit
      :hours
    end
  end
end
