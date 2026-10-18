require_relative './lib/Duration/VERSION'

class Gem::Specification
  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'duration.rb'
  spec.version = Duration::VERSION

  spec.summary = "Objects for handling durations of time."
  spec.description = "The unit is the class rather than a decoration upon a number of seconds, so a Minutes holds minutes and no unit is privileged as a base. Nothing is normalised at construction and conversions divide by exact ratios, so an Integer or a Rational stays exact the whole way through, with to_f left for the edge."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'http://github.com/thoran/duration'
  spec.license = 'MIT'

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5'

  spec.files = [
    Dir['lib/**/*.rb'],
    Dir['test/**/*.rb'],
    'CHANGELOG',
    'duration.rb.gemspec',
    'Gemfile',
    'LICENSE',
    'Rakefile',
    'README.md',
  ].flatten

  spec.development_dependencies = %w{
    minitest
    minitest-spec-context
    rake
  }
end
