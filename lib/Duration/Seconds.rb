# Duration/Seconds.rb
# Duration::Seconds

require_relative '../duration'

module Duration
  class Seconds
    include Common
    include Relative

    def to_nanoseconds
      to_milliseconds.to_nanoseconds
    end

    def to_microseconds
      to_milliseconds.to_microseconds
    end

    def to_milliseconds
      Duration::Milliseconds.new(@seconds * 1000)
    end

    def to_seconds
      self
    end

    def to_minutes
      Duration::Minutes.new(@seconds / 60r)
    end

    def to_hours
      to_minutes.to_hours
    end

    def to_days
      to_minutes.to_days
    end

    def to_weeks
      to_minutes.to_weeks
    end

    def to_months
      to_minutes.to_months
    end

    def to_i
      @seconds.to_i
    end

    def to_f
      @seconds.to_f
    end

    private

    def initialize(seconds = nil)
      @seconds = seconds
    end

    def unit
      :seconds
    end
  end
end
