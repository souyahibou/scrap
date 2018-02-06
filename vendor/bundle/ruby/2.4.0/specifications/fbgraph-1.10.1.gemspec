# -*- encoding: utf-8 -*-
# stub: fbgraph 1.10.1 ruby lib

Gem::Specification.new do |s|
  s.name = "fbgraph".freeze
  s.version = "1.10.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nicolas Santa".freeze]
  s.date = "2012-04-27"
  s.description = "A Gem for Facebook Open Graph API".freeze
  s.email = "nicolas55ar@gmail.com".freeze
  s.extra_rdoc_files = ["README.textile".freeze]
  s.files = ["README.textile".freeze]
  s.homepage = "http://github.com/nsanta/fbgraph".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.13".freeze
  s.summary = "A Gem for Facebook Open Graph API".freeze

  s.installed_by_version = "2.6.13" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<hashie>.freeze, [">= 1.0.0"])
      s.add_runtime_dependency(%q<oauth2>.freeze, [">= 0.5.0"])
      s.add_runtime_dependency(%q<faraday>.freeze, [">= 0.7.5"])
      s.add_runtime_dependency(%q<json>.freeze, [">= 1.0.0"])
      s.add_runtime_dependency(%q<rest-client>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<i18n>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 0.9.2"])
      s.add_development_dependency(%q<bundler>.freeze, ["> 1.0.0"])
      s.add_development_dependency(%q<fakeweb>.freeze, ["~> 1.3.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.6"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 3.9.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, [">= 0"])
      s.add_dependency(%q<hashie>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<oauth2>.freeze, [">= 0.5.0"])
      s.add_dependency(%q<faraday>.freeze, [">= 0.7.5"])
      s.add_dependency(%q<json>.freeze, [">= 1.0.0"])
      s.add_dependency(%q<rest-client>.freeze, [">= 0"])
      s.add_dependency(%q<i18n>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 0.9.2"])
      s.add_dependency(%q<bundler>.freeze, ["> 1.0.0"])
      s.add_dependency(%q<fakeweb>.freeze, ["~> 1.3.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.6"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<rdoc>.freeze, [">= 3.9.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<hashie>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<oauth2>.freeze, [">= 0.5.0"])
    s.add_dependency(%q<faraday>.freeze, [">= 0.7.5"])
    s.add_dependency(%q<json>.freeze, [">= 1.0.0"])
    s.add_dependency(%q<rest-client>.freeze, [">= 0"])
    s.add_dependency(%q<i18n>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 0.9.2"])
    s.add_dependency(%q<bundler>.freeze, ["> 1.0.0"])
    s.add_dependency(%q<fakeweb>.freeze, ["~> 1.3.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.6"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 3.9.0"])
  end
end
