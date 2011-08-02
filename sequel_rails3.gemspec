# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sequel_rails3/version"

Gem::Specification.new do |s|
  s.name        = "sequel_rails3"
  s.version     = SequelRails3::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Corin Langosch"]
  s.email       = ["info@netskin.com"]
  s.homepage    = "http://github.com/gucki/sequel_rails3"
  s.summary     = %q{Use sequel as a replacement for activerecord with rails 3}
  s.description = %q{This gem allows you to easily use sequel instead of activerecord with rails 3.x.x}

  s.rubyforge_project = "sequel_rails3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~>3.0"
  s.add_dependency "sequel", "~>3.0"

  s.add_development_dependency "rspec", "~>2.5"
  s.add_development_dependency "rspec-rails", "~>2.5"
end
