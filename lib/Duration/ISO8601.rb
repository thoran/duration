# Duration/ISO8601.rb
# Duration::ISO8601

module Duration
  module ISO8601
    FORMAT = /\AP(?=\d|T\d)(?:(?<weeks>\d+)W)?(?:(?<days>\d+)D)?(?:T(?=\d)(?:(?<hours>\d+)H)?(?:(?<minutes>\d+)M)?(?:(?<seconds>\d+)S)?)?\z/
    private_constant :FORMAT

    # An ISO 8601 duration, as PT1H2M3S, in the unit of the class extended.
    # Each component written is made in its own unit and summed into this one,
    # so the result is what the conversions give: exact, and an Integer where
    # they divide evenly.  Weeks and days are accepted, each having a fixed
    # length.  Years and months are refused, having none; M is months before
    # the T and minutes only after it.
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
end
