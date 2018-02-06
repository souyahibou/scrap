# -*- encoding: utf-8 -*-
# stub: webdrivers 3.2.4 ruby lib

Gem::Specification.new do |s|
  s.name = "webdrivers".freeze
  s.version = "3.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Titus Fortner".freeze]
  s.date = "2018-01-04"
  s.description = "Run Selenium tests more easily with install and updates for all supported webdrivers.".freeze
  s.email = ["titusfortner@gmail.com".freeze]
  s.homepage = "https://github.com/titusfortner/webdrivers".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.13".freeze
  s.summary = "Easy download and use of browser drivers.".freeze

  s.installed_by_version = "2.6.13" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
      s.add_runtime_dependency(%q<rubyzip>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<selenium-webdriver>.freeze, ["~> 3.0"])
    else
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
      s.add_dependency(%q<rubyzip>.freeze, ["~> 1.0"])
      s.add_dependency(%q<selenium-webdriver>.freeze, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
    s.add_dependency(%q<rubyzip>.freeze, ["~> 1.0"])
    s.add_dependency(%q<selenium-webdriver>.freeze, ["~> 3.0"])
  end
end
