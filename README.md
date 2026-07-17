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

## Usage

### Basic Duration Creation
```ruby
# Create durations using convenience methods
200.milliseconds        # => #<Milliseconds: @milliseconds=200>
1.second                # => #<Seconds: @seconds=1>
30.minutes              # => #<Minutes: @minutes=30>
2.hours                 # => #<Hours: @hours=2>
7.days                  # => #<Days: @days=7>
4.weeks                 # => #<Weeks: @weeks=4>
6.months                # => #<Months: @months=6>
```

### Conversions
```ruby
# Convert to integers
200.milliseconds.to_i   # => 200
1.second.to_i           # => 1
30.minutes.to_i         # => 30
2.hours.to_i            # => 2
7.days.to_i             # => 7
4.weeks.to_i            # => 4
6.months.to_i           # => 6

# Convert to floats
200.milliseconds.to_f   # => 200.0
1.second.to_f           # => 1.0
30.minutes.to_f         # => 30.0
2.hours.to_f            # => 2.0
7.days.to_f             # => 7.0
4.weeks.to_f            # => 4.0
6.months.to_f           # => 6.0

# Convert between units
90.minutes.to_hours             # => #<Hours: @hours=1.5>
1.5.hours.to_minutes            # => #<Minutes: @minutes=90>
1.day.to_seconds                # => #<Seconds: @seconds=86400>

# Chain conversions
90.minutes.to_hours.to_f        # => 1.5
1.5.hours.to_minutes.to_i       # => 90
1.day.to_seconds.to_i           # => 86400
```

### Time Calculations
```ruby
# The past
1.millisecond.ago               # => #<Time:> (now - 1.millisecond.to_seconds.to_f)
2.seconds.ago                   # => #<Time:> (now - 2.seconds.to_seconds.to_f)
3.minutes.ago                   # => #<Time:> (now - 3.minutes.to_seconds.to_f)
4.hours.ago                     # => #<Time:> (now - 4.hours.to_seconds.to_f)
5.days.ago                      # => #<Time:> (now - 5.days.to_seconds.to_f)
6.weeks.ago                     # => #<Time:> (now - 6.weeks.to_seconds.to_f)
7.months.ago                    # => #<Time:> (now - 7.months.to_seconds.to_f)

# The future
1.millisecond.hence             # => #<Time:> (now + 1.millisecond.to_seconds.to_f)
2.seconds.hence                 # => #<Time:> (now + 2.seconds.to_seconds.to_f)
3.minutes.hence                 # => #<Time:> (now + 3.minutes.to_seconds.to_f)
4.hours.hence                   # => #<Time:> (now + 4.hours.to_seconds.to_f)
5.days.hence                    # => #<Time:> (now + 5.days.to_seconds.to_f)
6.weeks.hence                   # => #<Time:> (now + 6.weeks.to_seconds.to_f)
7.months.hence                  # => #<Time:> (now + 7.months.to_seconds.to_f)
```

### A Note on Months

`Months` is the odd one out. Every other unit is a fixed quantity with an exact
ratio to every other, but a month is a calendar operation whose length depends
on which month. The conversions use the Gregorian mean month (2629746 seconds),
so they are honest only as a statistical average:

```ruby
12.months.to_days               # => 365.2425, the Gregorian mean year
```

Two actual calendar months are anywhere from 59 to 62 days, while the mean gives
about 60.87 — no particular pair of months. No single constant can be right.

For the same reason `ago` and `hence` are not calendar-correct on `Months`: one
month before the 15th of March is the 15th of February to a calendar, but the
mean lands on the 12th. Where the calendar matters, reach for a date-anchored
type such as month.rb.

## Contributing

1. Fork it (https://github.com/thoran/duration.rb/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

## License

MIT
