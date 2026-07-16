# duration.rb

## Description

Objects for handling durations of time.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'duration.rb'
```

And then execute:
```shell
$ bundle
```

Or install directly:
```shell
$ gem install duration.rb
```

## Philosophy

This is the anti-`ActiveSupport::Duration`. There, every duration is really a
number of seconds and the unit is decoration: `1.hour == 3600`. Here the unit
*is* the class. A `Minutes` holds minutes — not seconds it renders as minutes —
so `30.minutes.to_i` is `30`, not `1800`. No unit is privileged; there is no
base. Conversion is a behaviour (`to_hours`), not a representation.

Because nothing is normalised at construction, exactness is yours to keep: hand
a constructor an `Integer` or a `Rational` and it stays exact all the way
through, since conversions divide by exact ratios rather than through a float.
Hand it a `Float` and it stays a `Float` — the library never manufactures
precision and never silently discards it.

```ruby
Duration::Minutes.new(5).to_hours.to_f   # => 0.08333333333333333
Duration::Minutes.new(5).to_hours        # holds exactly 1/12, not 0.0833...
(Duration::Hours.new(1) - Duration::Minutes.new(50)).to_minutes.to_f
                                         # => 10.0 exactly (no float drift)
```

## Loading

```ruby
require 'duration'          # the duration classes only

require 'duration-numeric'  # opt in to the Numeric sugar (5.minutes, etc.),
                            # which monkeypatches Numeric
```

The examples below use the `Numeric` sugar, so they assume
`require 'duration-numeric'`. Without it, construct durations directly with
`Duration::Minutes.new(5)` and friends.

## Usage

### Basic Duration Creation
```ruby
# Create durations using convenience methods
500.nanoseconds         # => #<Nanoseconds @nanoseconds=500>
500.microseconds        # => #<Microseconds @microseconds=500>
200.milliseconds        # => #<Milliseconds @milliseconds=200>
1.second                # => #<Seconds @seconds=1>
30.minutes              # => #<Minutes @minutes=30>
2.hours                 # => #<Hours @hours=2>
7.days                  # => #<Days @days=7>
4.weeks                 # => #<Weeks @weeks=4>
6.months                # => #<Months @months=6>
```

### Conversions
```ruby
# The number is in the unit's own terms, not a base:
30.minutes.to_i         # => 30 (not 1800)
30.minutes.to_f         # => 30.0

# Convert between units. The result is exact (a Rational internally) when the
# input is exact; call to_f at the edge for a float.
90.minutes.to_hours             # => #<Hours @hours=(3/2)>
90.minutes.to_hours.to_f        # => 1.5
1.5.hours.to_minutes.to_i       # => 90
1.day.to_seconds.to_i           # => 86400
5.minutes.to_hours.to_f         # => 0.08333333333333333
```

### Arithmetic and Comparison
```ruby
# Durations add and subtract, with the left operand's unit deciding the result:
5.minutes + 30.seconds          # => #<Minutes @minutes=(11/2)>  (5.5 minutes)
5.minutes - 30.seconds          # => #<Minutes @minutes=(9/2)>   (4.5 minutes)
5.minutes + 30                  # => TypeError (a bare number has no unit)

# Durations are Comparable, across units and exactly:
5.minutes == 300.seconds        # => true
90.seconds > 1.minute           # => true
[1.hour, 30.seconds, 5.minutes].sort
                                # => [30.seconds, 5.minutes, 1.hour]
```

### Time Calculations
```ruby
# The past
2.seconds.ago                   # => #<Time:> (now - 2.seconds.to_seconds.to_f)
3.minutes.ago                   # => #<Time:> (now - 3.minutes.to_seconds.to_f)
4.hours.ago                     # => #<Time:> (now - 4.hours.to_seconds.to_f)
5.days.ago                      # => #<Time:> (now - 5.days.to_seconds.to_f)
6.weeks.ago                     # => #<Time:> (now - 6.weeks.to_seconds.to_f)

# The future
2.seconds.hence                 # => #<Time:> (now + 2.seconds.to_seconds.to_f)
3.minutes.hence                 # => #<Time:> (now + 3.minutes.to_seconds.to_f)
4.hours.hence                   # => #<Time:> (now + 4.hours.to_seconds.to_f)
5.days.hence                    # => #<Time:> (now + 5.days.to_seconds.to_f)
6.weeks.hence                   # => #<Time:> (now + 6.weeks.to_seconds.to_f)
```

### A Note on Months
`Months` is the odd one out. Every other unit is a fixed quantity with an exact
ratio to every other; a month is a calendar operation whose length depends on
the calendar. Its conversions use the Gregorian mean month (2629746 seconds),
so they are honest only as a statistical average, never as calendar-correct
arithmetic. Its `ago`/`hence` inherit this — they displace by the mean month,
so they are approximate rather than calendar-correct; reach for a
calendar-anchored type such as `month.rb` when that matters. `Months` is slated
for removal in 0.5.0.

## Contributing

1. Fork it (https://github.com/thoran/duration.rb/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

## License

MIT
