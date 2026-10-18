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

require 'duration-classes'  # opt in to the unit classes at the top level
                            # (Days rather than Duration::Days)
```

Those are three ways in rather than three lines to write. Each stands alone, the
two opt-in files requiring the core themselves, so `require 'duration-classes'` is
a complete line and wants no `require 'duration'` above it. They are independent of
each other, so a program which wants both the sugar and the top-level names asks
for both.

The examples below use the `Numeric` sugar, so they assume
`require 'duration-numeric'`. Without it durations are constructed directly with
`Duration::Minutes.new(5)` and so on.

The first two requires declare where the unit classes are without reading them. A
unit file is read when its class is first named, so a program dealing in seconds
and minutes reads the files for seconds and minutes and leaves the rest unread.
The third is different, and says so below.

### Naming the classes

The unit classes are `Duration::Days` and its siblings. With the sugar,
construction never names one — `45.days` reaches the same class — so the prefix is
left for the two places a constant is unavoidable, type checks and dispatch —
`value.is_a?(Duration::Common)`, or a `case` over the units.

`require 'duration-classes'` takes the nine unit classes and names them at the top
level, so those read as `Days` and `Hours`. It is the counterpart to the `Numeric`
sugar — that one adds nine methods, this one nine constants — and like it, it is
opt-in by require rather than something `require 'duration'` does to you.

```ruby
require 'duration-classes'

Days.new(45)                # => Duration::Days(45)
```

The classes keep their own names, so `inspect` is unchanged. `Common`, `Relative`,
`ISO8601` and `VERSION` stay where they are: the first three are modules rather than
classes, `Common` and `Relative` being what a type check names, and `VERSION` is a
word an including program is likely to want for itself.

**It is eager**, where the sugar is not: requiring it reads all nine unit files,
against the two a sugar-only program reads. A constant assignment resolves at once
where a method body waits to be called, so it cannot be otherwise — the price of
asking for all nine names, charged only to a program which asks.

**It assigns into the top level**, so a name already taken is replaced — with a
warning, at least. The order without a warning is the one to watch:

```ruby
require 'duration-classes'
class Days                      # not a class of your own — this reopens
  def self.mine; end            # Duration::Days and adds a method to it
end
```

`class Days` finds the name bound and reopens what it names, so a program which
meant to declare its own has extended the gem's instead. Where a program has its own
vocabulary to protect, reach for the units through `Duration::`.

Where fewer names will do, naming them yourself costs nothing and stays lazy:

```ruby
Days = Duration::Days
Hours = Duration::Hours
```

Two files are read and two names are taken, and the pair reads as a declaration of
which units this program deals in — the same thing the loading story above says
about the files.

`include Duration` is the remaining way in, and the last to reach for. Inside a
class it is scoped and unremarkable, and it brings `Common` along, which
`duration-classes` does not:

```ruby
class Portfolio
  include Duration
  def hold_period; Days.new(45); end
  def duration?(value); value.is_a?(Common); end
end
```

At the top level it includes into `Object`, putting all thirteen constants into
global scope — the nine units, `Common`, `Relative`, `ISO8601` and `VERSION`. A
constant of your own still wins there, but a name you never gave resolves silently
rather than raising, and a second library included the same way and carrying the
same name wins by include order alone. `Common` is the likeliest to be met twice.

## Usage

### Basic Duration Creation
```ruby
# Create durations using convenience methods
500.nanoseconds         # => Duration::Nanoseconds(500)
500.microseconds        # => Duration::Microseconds(500)
200.milliseconds        # => Duration::Milliseconds(200)
1.second                # => Duration::Seconds(1)
30.minutes              # => Duration::Minutes(30)
2.hours                 # => Duration::Hours(2)
7.days                  # => Duration::Days(7)
4.weeks                 # => Duration::Weeks(4)
6.months                # => Duration::Months(6)
```

### Conversions
```ruby
# The number is in the unit's own terms, not a base:
30.minutes.to_i         # => 30 (not 1800)
30.minutes.to_f         # => 30.0

# Convert between units. The result is exact (a Rational internally) when the
# input is exact; call to_f at the edge for a float.
90.minutes.to_hours             # => Duration::Hours((3/2))
90.minutes.to_hours.to_f        # => 1.5
1.5.hours.to_minutes.to_i       # => 90
1.day.to_seconds.to_i           # => 86400
5.minutes.to_hours.to_f         # => 0.08333333333333333
```

### ISO 8601

Every unit reads an ISO 8601 duration, as APIs such as YouTube's give them, with
`from_iso8601`. Any subset of weeks, days, hours, minutes and seconds is accepted,
and the result is in the unit asked of.

```ruby
Duration::Seconds.from_iso8601('PT1H2M3S')  # => Duration::Seconds(3723)
Duration::Minutes.from_iso8601('PT1H2M3S')  # => Duration::Minutes((1241/20))
Duration::Days.from_iso8601('P2W')          # => Duration::Days(14)
Duration::Seconds.from_iso8601('P0D')       # => Duration::Seconds(0)
```

Each component written is made in its own unit and summed into the one asked of,
so the result is what the conversions give: exact, and an `Integer` where they
divide evenly. Seconds is the unit in which every such string is a whole number.

It is a named constructor rather than a `String` accepted by `new`, so the
constructor still takes a quantity and holds it, and a string in some other form
is left free to have a constructor of its own.

A week is seven days and a day 24 hours, both being fixed lengths. Years and months
are not, so `P1Y` and `P1M` raise `ArgumentError` rather than being counted by some
average; `M` is minutes only after the `T`. Anything else which is not of the form
`P#W#DT#H#M#S` raises `ArgumentError` too, which includes a fraction (`PT1.5S`) and
a sign (`-P1D`). `Months` reads weeks and days by the mean month, as its conversions
do, and refuses `P1M` with the rest: a calendar month is not the mean month.

Every duration writes itself back out with `to_iso8601`, leaving out what is zero:

```ruby
Duration::Seconds.new(3723).to_iso8601      # => "PT1H2M3S"
Duration::Minutes.new(90).to_iso8601        # => "PT1H30M"
Duration::Weeks.new(2).to_iso8601           # => "P14D"
Duration::Seconds.new(0).to_iso8601         # => "PT0S"
```

Each quantity is taken whole through the units' own conversions, so what is written
is read back as the duration it came from. Weeks are written as days, ISO 8601
allowing them only alone or by its 2019 extension. A duration which is not a whole
number of seconds, `Duration::Milliseconds.new(1500)` for one, raises
`ArgumentError`, there being no fraction to write it with exactly, and so does a
negative one, there being no sign. `Months` writes the mean month out in full:
`Duration::Months.new(1).to_iso8601` is `"P30DT10H29M6S"`.

Reading is a class method and writing an instance method, so `Duration::ISO8601`
holds a mixin for each: `ISO8601::Reader`, which each unit extends, and
`ISO8601::Writer`, which `Common` includes.

### Rendering

`to_s` names the quantity and the unit — the unit being the class, naming it says
which duration this is without repeating it.

```ruby
45.days.to_s            # => "45 days"
1.day.to_s              # => "1 day"
1.5.hours.to_s          # => "1.5 hours"
```

The quantity prints as it is held. A Rational which came out whole prints as a whole
number, and one which did not stays a ratio rather than being expanded into a decimal
it is not:

```ruby
45.days.to_weeks.to_s   # => "45/7 weeks"
90.minutes.to_hours.to_s  # => "3/2 hours"
```

Call `to_f` where a decimal is wanted, as elsewhere — the rounding happens upon
request and not before.

`inspect` is the other form: the class and the quantity as it is actually held. It is
the one place an `Integer` 45 and a `Rational` 45/1 can be told apart, `to_s` rendering
both as `"45 days"`.

```ruby
45.days.inspect             # => "Duration::Days(45)"
45.days.to_weeks.inspect    # => "Duration::Weeks((45/7))"
{held_for: 45.days}.inspect # => "{held_for: Duration::Days(45)}"
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
                                # => [Duration::Seconds(30), Duration::Minutes(5), Duration::Hours(1)]

# Scaled by a number, a duration stays a duration and keeps its unit:
5.minutes * 3                   # => #<Minutes @minutes=15>
1.hour / 4                      # => #<Hours @hours=(1/4)>
1.second / 3                    # => #<Seconds @seconds=(1/3)>  (not 0)

# Divided by a duration, the units cancel and a plain number is left. It is a
# Rational when both quantities are exact, as Numeric#quo gives, so it compares
# and calculates as the number it is; call to_f at the edge.
1.hour / 30.minutes             # => (2/1)
1.second / 3.milliseconds       # => (1000/3)

# There is no unit of time squared, so this is refused rather than answered:
5.minutes * 3.minutes           # => TypeError
```

### Time Calculations
```ruby
# The past
2.seconds.ago                   # => #<Time:> (now - 2.seconds.to_seconds.to_f)
3.minutes.ago                   # => #<Time:> (now - 3.minutes.to_seconds.to_f)
4.hours.ago                     # => #<Time:> (now - 4.hours.to_seconds.to_f)
5.days.ago                      # => #<Time:> (now - 5.days.to_seconds.to_f)
6.weeks.ago                     # => #<Time:> (now - 6.weeks.to_seconds.to_f)

# Months too, but by the Gregorian mean month rather than a calendar month, so
# the result is approximate. See A Note on Months below.
6.months.ago                    # => #<Time:> (now - 6.months.to_seconds.to_f)

# The future
2.seconds.hence                 # => #<Time:> (now + 2.seconds.to_seconds.to_f)
3.minutes.hence                 # => #<Time:> (now + 3.minutes.to_seconds.to_f)
4.hours.hence                   # => #<Time:> (now + 4.hours.to_seconds.to_f)
5.days.hence                    # => #<Time:> (now + 5.days.to_seconds.to_f)
6.weeks.hence                   # => #<Time:> (now + 6.weeks.to_seconds.to_f)

# Again by the mean month, and so approximate:
6.months.hence                  # => #<Time:> (now + 6.months.to_seconds.to_f)
```

### A Note on Months
`Months` is the odd one out. Every other unit is a fixed quantity with an exact
ratio to every other; a month is a calendar operation whose length depends on
the calendar. Its conversions use the Gregorian mean month (2629746 seconds),
so they are honest only as a statistical average, never as calendar-correct
arithmetic. Its `ago`/`hence` inherit this — they displace by the mean month,
so they are approximate rather than calendar-correct; reach for a
calendar-anchored type such as `month.rb` when that matters. `Months` is
therefore slated for removal.

## Contributing

1. Fork it (https://github.com/thoran/duration/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

## License

MIT
