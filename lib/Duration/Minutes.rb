# Duration/Minutes.rb
# Duration::Minutes

require_relative '../duration'

module Duration
  class Minutes
    include Common
    include Relative
    extend ISO8601::Reader

    def to_nanoseconds
      to_seconds.to_nanoseconds
    end

    def to_microseconds
      to_seconds.to_microseconds
    end

    def to_milliseconds
      to_seconds.to_milliseconds
    end

    def to_seconds
      Duration::Seconds.new(@minutes * 60)
    end

    def to_minutes
      self
    end

    def to_hours
      Duration::Hours.new(@minutes / 60r)
    end

    def to_days
      to_hours.to_days
    end

    def to_weeks
      to_hours.to_weeks
    end

    def to_months
      to_hours.to_months
    end

    def to_i
      @minutes.to_i
    end

    def to_f
      @minutes.to_f
    end

    private

    def initialize(minutes = nil)
      @minutes = minutes
    end

    def unit
      :minutes
    end
  end
end
