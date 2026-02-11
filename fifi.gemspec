# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "fifi"
  spec.version       = "0.1.0"
  spec.authors       = ["Fifi Contributors"]
  spec.email         = []

  spec.summary       = "Install or download Google Fonts from the terminal."
  spec.description   = "Fifi installs or downloads Google Fonts with a simple CLI."
  spec.homepage      = "https://github.com/Greyoxide/fifi"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE.txt"]
  spec.bindir        = "bin"
  spec.executables   = ["fifi"]
  spec.require_paths = ["lib"]

  spec.metadata = {
    "source_code_uri" => "https://github.com/Greyoxide/fifi",
    "bug_tracker_uri" => "https://github.com/Greyoxide/fifi/issues"
  }

  # Uses standard library (open-uri, json)
end
