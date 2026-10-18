# Duration/ISO8601.rb
# Duration::ISO8601

# Reading is a class method and writing an instance method, so each half is a
# mixin of its own: a single module both extended and included would put every
# method upon both sides, where half of them could only fail.

module Duration
  module ISO8601
    # Extended into each unit.
    module Reader
      FORMAT = /\AP(?=\d|T\d)(?:(?<weeks>\d+)W)?(?:(?<days>\d+)D)?(?:T(?=\d)(?:(?<hours>\d+)H)?(?:(?<minutes>\d+)M)?(?:(?<seconds>\d+)S)?)?\z/
      private_constant :FORMAT

      # An ISO 8601 duration, as PT1H2M3S, in the unit of the class extended.
      # Each component written is made in its own unit and summed into this
      # one, so the result is what the conversions give: exact, and an Integer
      # where they divide evenly.  Weeks and days are accepted, each having a
      # fixed length.  Years and months are refused, having none; M is months
      # before the T and minutes only after it.
      def from_iso8601(string)
        if /\AP[^T]*[YM]/.match?(string)
          raise ArgumentError, "#{string.inspect} has years or months, which have no fixed length"
        end
        unless (match = FORMAT.match(string))
          raise ArgumentError, "#{string.inspect} is not an ISO 8601 duration"
        end
        iso8601_components(match).sum(new(0))
      end

      private

      # The captures are named for the units, so each names its own class.
      def iso8601_components(match)
        match.named_captures.compact.map{|unit, quantity| Duration.const_get(unit.capitalize).new(quantity.to_i)}
      end
    end

    # Included into Common.
    module Writer
      # The duration as P#DT#H#M#S, leaving out what is zero, and PT0S where
      # all of it is.  Weeks are not written, ISO 8601 allowing them only alone
      # or by its 2019 extension.  A part second and a negative duration are
      # refused, the one having no exact form here and the other no sign.
      def to_iso8601
        days, *clock = iso8601_quantities
        date = days.zero? ? '' : "#{days}D"
        time = clock.zip(%w{H M S}).reject{|quantity, _| quantity.zero?}.map(&:join).join
        return 'PT0S' if date.empty? && time.empty?
        time.empty? ? "P#{date}" : "P#{date}T#{time}"
      end

      private

      # Each quantity is taken whole through the unit's own conversion and
      # subtracted before the next, so no ratio is written down twice.
      def iso8601_quantities
        rest = iso8601_seconds
        %i{days hours minutes seconds}.map do |unit|
          quantity = rest.send(:"to_#{unit}").to_i
          rest -= Duration.const_get(unit.capitalize).new(quantity)
          quantity
        end
      end

      def iso8601_seconds
        seconds = to_seconds
        whole = Duration::Seconds.new(seconds.to_i)
        if seconds < Duration::Seconds.new(0)
          raise ArgumentError, "#{inspect} is negative, and ISO 8601 has no sign"
        end
        unless seconds == whole
          raise ArgumentError, "#{inspect} is not a whole number of seconds"
        end
        whole
      end
    end
  end
end
