# Duration/Microseconds.rb
# Duration::Microseconds

require_relative '../duration'

module Duration
  class Microseconds
    include Common
    include Relative
    extend ISO8601

    def to_nanoseconds
      Duration::Nanoseconds.new(@microseconds * 1000)
    end

    def to_microseconds
      self
    end

    def to_milliseconds
      Duration::Milliseconds.new(@microseconds / 1000r)
    end

    def to_seconds
      to_milliseconds.to_seconds
    end

    def to_minutes
      to_milliseconds.to_minutes
    end

    def to_hours
      to_milliseconds.to_hours
    end

    def to_days
      to_milliseconds.to_days
    end

    def to_weeks
      to_milliseconds.to_weeks
    end

    def to_months
      to_milliseconds.to_months
    end

    def to_i
      @microseconds.to_i
    end

    def to_f
      @microseconds.to_f
    end

    private

    def initialize(microseconds = nil)
      @microseconds = microseconds
    end

    def unit
      :microseconds
    end
  end
end
