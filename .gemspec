# frozen_string_literal: true

require_relative 'lib/daily/version'

Gem::Specification.new do |spec|
  spec.name = 'daily'
  spec.version = Daily::VERSION
  spec.required_ruby_version = '>= 3.2.0'
end
