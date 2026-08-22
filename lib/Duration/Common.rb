# Duration/Common.rb
# Duration::Common

module Duration
  module Common
    include Comparable

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
  end
end
