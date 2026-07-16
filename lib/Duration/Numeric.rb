# Duration/Numeric.rb
# Duration::Numeric

require_relative '../Duration'

module Duration
  module Numeric
    def nanoseconds
      Duration::Nanoseconds.new(self)
    end
    alias_method :nanosecond, :nanoseconds

    def microseconds
      Duration::Microseconds.new(self)
    end
    alias_method :microsecond, :microseconds

    def milliseconds
      Duration::Milliseconds.new(self)
    end
    alias_method :millisecond, :milliseconds

    def seconds
      Duration::Seconds.new(self)
    end
    alias_method :second, :seconds

    def minutes
      Duration::Minutes.new(self)
    end
    alias_method :minute, :minutes

    def hours
      Duration::Hours.new(self)
    end
    alias_method :hour, :hours

    def days
      Duration::Days.new(self)
    end
    alias_method :day, :days

    def weeks
      Duration::Weeks.new(self)
    end
    alias_method :week, :weeks

    def months
      Duration::Months.new(self)
    end
    alias_method :month, :months
  end
end

Numeric.include(Duration::Numeric)
