require_relative './lib/Duration/VERSION'

Gem::Specification.new do |spec|
  spec.name = 'duration.rb'

  spec.version = Duration::VERSION
  spec.date = '2025-10-25'

  spec.summary = "Objects for handling durations of time."
  spec.description = "Objects for handling durations of time."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'http://github.com/thoran/duration.rb'
  spec.license = 'Ruby'

  spec.required_ruby_version = '>= 2.5'

  spec.files = [
    'CHANGELOG',
    'duration.rb.gemspec',
    'Gemfile',
    Dir['lib/**/*.rb'],
    'README.md',
    Dir['test/**/*.rb']
  ].flatten
  spec.require_paths = ['lib']
end
