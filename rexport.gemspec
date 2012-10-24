$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rexport/version"

Gem::Specification.new do |s|
  s.name = 'rexport'
  s.version = Rexport::VERSION
  s.authors = ['Aaron Baldwin', 'Jonathan Garvin', 'WWIDEA, Inc']
  s.email = ["developers@wwidea.org"]
  s.homepage = 'https://github.com/wwidea/rexport'
  s.summary = 'Ruby on Rails gem to manage exports.'
  s.description = 'Ruby on Rails gem to manage exports.'
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  
  s.add_dependency('rails','>= 3.1.0')
  
  s.add_development_dependency('rake','>= 0.9.2')
  s.add_development_dependency('rdoc','>= 3.12')
  s.add_development_dependency('factory_girl','~> 2.5.0')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('mocha')
end
