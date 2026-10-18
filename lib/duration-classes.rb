# duration-classes.rb

# The unit classes at the top level, for a program which would rather write
# Days than Duration::Days.  Opt-in by require, as the Numeric sugar is, and
# the counterpart to it: that one adds nine methods, this one nine constants.
#
# It takes only the classes.  Common, Relative, ISO8601 and VERSION stay where
# they are, the first three being modules rather than classes, Common and
# Relative being what a type check names, and VERSION being a word an including
# program is likely to want for itself.
#
# Unlike the sugar it is eager, and cannot be otherwise: a method body naming
# Duration::Seconds is not evaluated until the method is called, where a
# constant assignment resolves its right-hand side at once and so reads every
# unit.  Requiring this file therefore costs the whole library, which is the
# price of asking for all nine names by name.

require_relative 'duration'

Nanoseconds  = Duration::Nanoseconds
Microseconds = Duration::Microseconds
Milliseconds = Duration::Milliseconds
Seconds      = Duration::Seconds
Minutes      = Duration::Minutes
Hours        = Duration::Hours
Days         = Duration::Days
Weeks        = Duration::Weeks
Months       = Duration::Months
