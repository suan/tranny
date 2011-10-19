# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tranny/version"

Gem::Specification.new do |s|
  s.name        = "tranny"
  s.version     = Tranny::VERSION
  s.authors     = ["Josh Krueger"]
  s.email       = ["joshsinbox@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Tranny transforms your hashes}
  s.description = %q{Tranny provides a simple DSL to transform arbitrary hashes into another, more arbitrary hash. Yay.}

  s.rubyforge_project = "tranny"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
