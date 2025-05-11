# frozen_string_literal: true

require_relative "lib/phlexi/field/version"

Gem::Specification.new do |spec|
  spec.name = "phlexi-field"
  spec.version = Phlexi::Field::VERSION
  spec.authors = ["Stefan Froelich"]
  spec.email = ["sfroelich01@gmail.com"]

  spec.summary = "Base fields for the Phlexi libraries"
  spec.description = "Base fields for the Phlexi libraries"
  spec.homepage = "https://github.com/radioactive-labs/phlexi-field"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.2"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "phlex", "~> 2.0"
  spec.add_dependency "activesupport", ">= 7.1"
  spec.add_dependency "zeitwerk"
  spec.add_dependency "fiber-local"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "standard"
  # spec.add_development_dependency "brakeman"
  spec.add_development_dependency "bundle-audit"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "combustion"
  spec.add_development_dependency "nokogiri"
end
