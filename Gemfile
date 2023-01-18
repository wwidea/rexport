source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in rexport.gemspec
gemspec

group :test do
  gem 'simplecov'
end

group :development do
  gem 'factory_bot'
  gem 'guard-minitest'
  gem 'guard'
  gem 'mocha'
  gem 'sqlite3'
  gem 'terminal-notifier-guard'
end
