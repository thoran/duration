# Duration/ISO8601.rb
# Duration::ISO8601

# Reading is a class method and writing an instance method, so each half is a
# mixin of its own: a single module both extended and included would put every
# method upon both sides, where half of them could only fail.

module Duration
  module ISO8601
    # Extended into each unit.
    module Reader
      QUANTITY = '\d+(?:[.,]\d+)?'
      FORMAT = /\AP(?=\d|T\d)(?:(?<months>#{QUANTITY})M)?(?:(?<weeks>#{QUANTITY})W)?(?:(?<days>#{QUANTITY})D)?(?:T(?=\d)(?:(?<hours>#{QUANTITY})H)?(?:(?<minutes>#{QUANTITY})M)?(?:(?<seconds>#{QUANTITY})S)?)?\z/
      private_constant :QUANTITY, :FORMAT

      # An ISO 8601 duration, as PT1H2M3S, in the unit of the class extended.
      # Each component written is made in its own unit and summed into this
      # one, so the result is what the conversions give: exact, and an Integer
      # where they divide evenly.  The last component may have a fraction, as
      # the standard allows.  Years are refused, having no fixed length.
      # Months, which have none either, are read only by Months, whose month is
      # the mean month; M is months before the T and minutes only after it.
      def from_iso8601(string)
        iso8601_components(iso8601_match(string)).sum(new(0))
      end

      private

      def iso8601_match(string)
        if /\AP[^T]*Y/.match?(string)
          raise ArgumentError, "#{string.inspect} has years, which have no fixed length"
        end
        match = FORMAT.match(string)
        unless match && iso8601_fraction_last?(match)
          raise ArgumentError, "#{string.inspect} is not an ISO 8601 duration"
        end
        if match[:months] && self != Duration::Months
          raise ArgumentError, "#{string.inspect} has months, which only Duration::Months reads, as the mean month"
        end
        match
      end

      def iso8601_fraction_last?(match)
        match.captures.compact[0...-1].none?{|quantity| quantity.match?(/[.,]/)}
      end

      # The captures are named for the units, so each names its own class.
      def iso8601_components(match)
        match.named_captures.compact.map do |unit, quantity|
          Duration.const_get(unit.capitalize).new(iso8601_quantity(quantity))
        end
      end

      def iso8601_quantity(quantity)
        quantity.match?(/[.,]/) ? quantity.tr(',', '.').to_r : quantity.to_i
      end
    end

    # Included into Common.
    module Writer
      DESIGNATORS = {months: 'M', weeks: 'W', days: 'D', hours: 'H', minutes: 'M', seconds: 'S'}
      CLOCK = %i{hours minutes seconds}
      SPLIT = %i{days hours minutes seconds}
      private_constant :DESIGNATORS, :CLOCK, :SPLIT

      # The duration in its own unit's designator, as it is held, as the rest of
      # the library keeps the unit: 90 minutes as PT90M and two weeks as P2W, a
      # unit smaller than a second having none and so being written in seconds.
      # split: true splits it into days, hours, minutes and seconds instead, as
      # PT1H2M3S, and split: given units into those, largest first, leaving out
      # what is zero.  It is split as Common#split splits, each unit but the last
      # taking its whole part and the last what remains, so that only the last
      # can have a fraction, as the standard requires.  That fraction is
      # written exactly where it has a finite decimal, and otherwise only when
      # given the number of fraction digits to round it to, as Time#iso8601 is.
      # A negative duration is refused, ISO 8601 having no sign.
      def to_iso8601(fraction_digits = nil, split: false)
        iso8601_validate
        units = iso8601_units(split)
        date, clock = iso8601_parts(units, fraction_digits).partition{|part_unit, _| !CLOCK.include?(part_unit)}
        date, clock = [date, clock].map{|parts| parts.map{|part_unit, number| "#{number}#{DESIGNATORS[part_unit]}"}.join}
        clock.empty? ? "P#{date}" : "P#{date}T#{clock}"
      end

      private

      def iso8601_validate
        raise ArgumentError, "#{inspect} is negative, and ISO 8601 has no sign" if quantity.negative?
        raise ArgumentError, "#{inspect} is not finite" unless quantity.finite?
      end

      def iso8601_units(split)
        return SPLIT if split == true
        return [DESIGNATORS.key?(unit) ? unit : :seconds] unless split
        units = Array(split)
        order = DESIGNATORS.keys
        unless units.any? && units.all?{|split_unit| order.include?(split_unit)} && units.each_cons(2).all?{|larger, smaller| order.index(larger) < order.index(smaller)}
          raise ArgumentError, "split: wants units from #{order.join(', ')}, largest first"
        end
        units
      end

      # Zero is left out, unless all of it is, when it is written in the last unit.
      def iso8601_parts(units, fraction_digits)
        quantities = units.zip(iso8601_cascade(units))
        kept = quantities.reject{|_, quantity| quantity.zero?}
        kept = [quantities.last] if kept.empty?
        kept.map do |part_unit, quantity|
          [part_unit, part_unit == units.last ? iso8601_number(quantity, fraction_digits) : quantity.to_s]
        end
      end

      def iso8601_cascade(units)
        iso8601_exact.split(*units.map{|part_unit| Duration.const_get(part_unit.capitalize)}).map{|part| part.quantity}
      end

      # A Float is taken as it prints, not as the binary fraction it holds.
      def iso8601_exact
        quantity.is_a?(Float) ? self.class.new(quantity.to_s.to_r) : self
      end

      def iso8601_number(quantity, fraction_digits)
        exact = quantity.to_r
        places = fraction_digits || iso8601_places(exact.denominator)
        unless places
          raise ArgumentError, "#{inspect} has no exact decimal, so wants the fraction digits to round it to"
        end
        iso8601_decimal((exact * 10**places).round, places)
      end

      # The fewest decimal places which hold the quantity exactly, or nil where
      # no number of them will.
      def iso8601_places(denominator)
        (0..denominator.bit_length).find{|places| (10**places % denominator).zero?}
      end

      def iso8601_decimal(scaled, places)
        digits = scaled.to_s.rjust(places + 1, '0')
        places.zero? ? digits : "#{digits[0...-places]}.#{digits[-places..-1]}"
      end
    end
  end
end
