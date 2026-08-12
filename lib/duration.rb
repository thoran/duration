# Duration.rb
# Duration

# Previously, neighbouring units which are used conversion methods used to be requires at the top of each file, so that every adjacent pair was a cycle and Ruby warned upon each under -w.

# Now, a unit file is read when its class is first named and not before, which is what lets a program dealing in seconds and minutes loads only Seconds and Minutes, so that units are may easily be left unused.

module Duration
  autoload :Common,       File.expand_path('Duration/Common', __dir__)
  autoload :Relative,     File.expand_path('Duration/Relative', __dir__)
  autoload :Nanoseconds,  File.expand_path('Duration/Nanoseconds', __dir__)
  autoload :Microseconds, File.expand_path('Duration/Microseconds', __dir__)
  autoload :Milliseconds, File.expand_path('Duration/Milliseconds', __dir__)
  autoload :Seconds,      File.expand_path('Duration/Seconds', __dir__)
  autoload :Minutes,      File.expand_path('Duration/Minutes', __dir__)
  autoload :Hours,        File.expand_path('Duration/Hours', __dir__)
  autoload :Days,         File.expand_path('Duration/Days', __dir__)
  autoload :Weeks,        File.expand_path('Duration/Weeks', __dir__)
  autoload :Months,       File.expand_path('Duration/Months', __dir__)
end

# VERSION is required rather than autoloaded, and is the one exception, as there nothing which will load it at runtime.

require_relative 'Duration/VERSION'
