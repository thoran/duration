# Duration/Common.rb
# Duration::Common

module Duration
  module Common
    include Comparable
    include ISO8601::Writer

    def +(other)
      combine(:+, other)
    end

    def -(other)
      combine(:-, other)
    end

    # A duration times a number is a duration.  A duration times a duration
    # would be time squared, which has no unit here and few enough anywhere, so
    # it is refused rather than quietly given some plausible answer.
    def *(other)
      if other.is_a?(Duration::Common)
        raise TypeError, "can't multiply #{self.class} by #{other.class}: there is no unit of time squared"
      end
      scale(:*, other)
    end

    # Divided by a number a duration stays a duration.  Divided by a duration it
    # becomes the dimensionless ratio of the two, the units having cancelled,
    # which is how a rate or a speedup is arrived at.
    def /(other)
      return ratio(other) if other.is_a?(Duration::Common)
      scale(:quo, other)
    end

    # As Numeric#divmod: how many whole times another duration goes into this
    # one, and what is left over, in this one's unit as + and - leave it.  The
    # quotient is floored, as Numeric's is, so the remainder takes the sign of
    # the duration divided by.
    def divmod(other)
      unless other.is_a?(Duration::Common)
        raise TypeError, "can't divmod #{self.class} by #{other.class}"
      end
      quotient, remainder = quantity.divmod(other.send(:"to_#{unit}").quantity)
      [quotient, self.class.new(remainder)]
    end

    def %(other)
      divmod(other).last
    end

    # The duration broken into the unit classes given, largest first, as 3723
    # seconds is an hour, two minutes and three seconds.  Each unit but the last
    # takes its whole part, through the units' own conversions, and the last
    # takes what remains exactly, so the parts always sum back to the whole.
    # The whole part is truncated rather than floored, unlike divmod's
    # quotient, so a negative duration splits into parts all of its own sign.
    def split(*units)
      split_validate(units)
      rest = self
      wholes = units[0...-1].map do |part_unit|
        whole = part_unit.new((rest / part_unit.new(1)).truncate)
        rest -= whole
        whole
      end
      wholes << (units.last.new(0) + rest)
    end

    # As Numeric#floor: to a whole number of this duration's own unit, or,
    # given a duration, to a whole multiple of that, in this one's unit as + and
    # - leave it.  A bare number is refused, since to Numeric it would mean
    # digits, and here it could as well mean a quantity of some unit.
    def floor(step = nil)
      approximate(:floor, step)
    end

    def ceil(step = nil)
      approximate(:ceil, step)
    end

    # half: decides a tie, as Numeric#round's does.  It counts in steps, so
    # :even goes to an even number of them rather than of this unit.
    def round(step = nil, half: nil)
      approximate(:round, step, half: half)
    end

    # Towards zero, where floor goes downward, as split takes its whole parts.
    def truncate(step = nil)
      approximate(:truncate, step)
    end

    def <=>(other)
      return nil unless other.is_a?(Duration::Common)
      quantity <=> other.send(:"to_#{unit}").quantity
    end

    # The unit is the class, so naming it says which duration this is without
    # repeating the class: 45 days rather than #<Duration::Days:0x000... The
    # quantity is rendered as it is held, an exact Rational staying exact, this
    # library manufacturing no precision it was not given and discarding none
    # it was.
    def to_s
      "#{rendered_quantity} #{quantity == 1 ? unit.to_s.chomp('s') : unit}"
    end

    # The class and the quantity as it is actually held, after measurand: to_s
    # is what a reader wants and inspect is what the object is.  It is the one
    # place the difference between an Integer 45 and a Rational 45/1 shows,
    # which in a library this careful about exactness is worth being able to
    # see.
    def inspect
      "#{self.class}(#{quantity.inspect})"
    end

    protected

    def quantity
      instance_variable_get(:"@#{unit}")
    end

    private

    # A Rational which came out whole prints as its numerator, since 45/1 days
    # says nothing 45 days does not.  A Rational which did not stays a ratio:
    # 45/7 weeks is what 45 days is, and 6.428571428571429 is not.
    def rendered_quantity
      quantity.is_a?(Rational) && quantity.denominator == 1 ? quantity.numerator.to_s : quantity.to_s
    end

    def combine(operator, other)
      unless other.is_a?(Duration::Common)
        raise TypeError, "can't combine #{self.class} with #{other.class}"
      end
      self.class.new(quantity.send(operator, other.send(:"to_#{unit}").quantity))
    end

    # Division goes through #quo rather than #/ so that an Integer quantity
    # divides exactly: 1.quo(3) is (1/3) where 1 / 3 is 0.  A Float quantity
    # stays a Float, this library manufacturing no precision it was not given.
    def scale(operator, other)
      unless other.is_a?(Numeric)
        raise TypeError, "can't scale #{self.class} by #{other.class}"
      end
      self.class.new(quantity.send(operator, other))
    end

    def ratio(other)
      quantity.quo(other.send(:"to_#{unit}").quantity)
    end

    # The step is taken into this unit before it is scaled, so the result is in
    # this unit and exact, the whole number of steps being exact whatever the
    # quantity.
    def approximate(method, step, **options)
      step ||= self.class.new(1)
      unless step.is_a?(Duration::Common)
        raise TypeError, "can't #{method} #{self.class} to #{step.class}"
      end
      step.send(:"to_#{unit}") * ratio(step).send(method, **options)
    end

    def split_validate(units)
      unless units.any? && units.all?{|part_unit| split_unit?(part_unit)} && units.each_cons(2).all?{|larger, smaller| larger.new(1) > smaller.new(1)}
        raise ArgumentError, "split wants unit classes, largest first"
      end
    end

    def split_unit?(part_unit)
      part_unit.is_a?(Class) && part_unit.include?(Duration::Common)
    end
  end
end
