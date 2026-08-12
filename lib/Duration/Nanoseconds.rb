# Duration/Nanoseconds.rb
# Duration::Nanoseconds

require_relative '../duration'

module Duration
  class Nanoseconds
    include Common
    include Relative

    def to_nanoseconds
      self
    end

    def to_microseconds
      Duration::Microseconds.new(@nanoseconds / 1000r)
    end

    def to_milliseconds
      to_microseconds.to_milliseconds
    end

    def to_seconds
      to_microseconds.to_seconds
    end

    def to_minutes
      to_microseconds.to_minutes
    end

    def to_hours
      to_microseconds.to_hours
    end

    def to_days
      to_microseconds.to_days
    end

    def to_weeks
      to_microseconds.to_weeks
    end

    def to_months
      to_microseconds.to_months
    end

    def to_i
      @nanoseconds.to_i
    end

    def to_f
      @nanoseconds.to_f
    end

    private

    def initialize(nanoseconds = nil)
      @nanoseconds = nanoseconds
    end

    def unit
      :nanoseconds
    end
  end
end
