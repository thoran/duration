# Duration/Milliseconds.rb
# Duration::Milliseconds

require_relative '../duration'

module Duration
  class Milliseconds
    include Common
    include Relative
    extend ISO8601

    def to_nanoseconds
      to_microseconds.to_nanoseconds
    end

    def to_microseconds
      Duration::Microseconds.new(@milliseconds * 1000)
    end

    def to_milliseconds
      self
    end

    def to_seconds
      Duration::Seconds.new(@milliseconds / 1000r)
    end

    def to_minutes
      to_seconds.to_minutes
    end

    def to_hours
      to_seconds.to_hours
    end

    def to_days
      to_seconds.to_days
    end

    def to_weeks
      to_seconds.to_weeks
    end

    def to_months
      to_seconds.to_months
    end

    def to_i
      @milliseconds.to_i
    end

    def to_f
      @milliseconds.to_f
    end

    private

    def initialize(milliseconds = nil)
      @milliseconds = milliseconds
    end

    def unit
      :milliseconds
    end
  end
end
