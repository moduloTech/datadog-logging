# frozen_string_literal: true

require_relative 'lib/datadog/logging/version'

Gem::Specification.new do |spec|
  spec.name = 'datadog-logging'
  spec.version = Datadog::Logging::VERSION
  spec.authors = ['Matthieu CIAPPARA']
  spec.email = ['ciappa_m@modulotech.fr']

  spec.summary = 'Methods, class and formatters to log efficiently in Datadog'
  spec.homepage = 'https://github.com/moduloTech/datadog-logging'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/moduloTech/datadog-logging/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'
end
