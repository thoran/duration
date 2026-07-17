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
  spec.description = "Objects for handling durations of time."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'http://github.com/thoran/duration.rb'
  spec.license = 'Ruby'

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5'

  spec.files = [
    'CHANGELOG',
    'duration.rb.gemspec',
    'Gemfile',
    Dir['lib/**/*.rb'],
    'Rakefile',
    'README.md',
    Dir['test/**/*.rb']
  ].flatten

  spec.development_dependencies = %w{
    minitest
    minitest-spec-context
    rake
  }
end
