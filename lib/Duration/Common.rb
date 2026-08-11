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

    protected

    def quantity
      instance_variable_get(:"@#{unit}")
    end

    private

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
