# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "fifi"
  spec.version       = "0.1.0"
  spec.authors       = ["forrest"]
  spec.email         = ["forrest@example.com"]

  spec.summary       = "Install or download Google Fonts from the terminal."
  spec.description   = "Fifi installs or downloads Google Fonts with a simple CLI."
  spec.homepage      = "https://example.com/fifi"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE.txt"]
  spec.bindir        = "bin"
  spec.executables   = ["fifi"]
  spec.require_paths = ["lib"]

  # Uses standard library (open-uri, json)
end
