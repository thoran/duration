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
  end
end
