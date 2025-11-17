# Set encoding to UTF-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
