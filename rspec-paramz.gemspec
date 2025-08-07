lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rspec/paramz/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-paramz"
  spec.version       = RSpec::Paramz::VERSION
  spec.authors       = ["fukayatsu"]
  spec.email         = ["fukayatsu@gmail.com"]

  spec.required_ruby_version = ">= 3.3.0"

  spec.summary       = "Simple Parameterized Test for RSpec."
  spec.description   = "Simple Parameterized Test for RSpec"
  spec.homepage      = "https://github.com/fukayatsu/rspec-paramz"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fukayatsu/rspec-paramz"
  spec.metadata["changelog_uri"] = "https://github.com/fukayatsu/rspec-paramz/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "prism"
  spec.add_runtime_dependency "rspec"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "onkcop"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
end
