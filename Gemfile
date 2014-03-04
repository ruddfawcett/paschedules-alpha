source 'https://rubygems.org'

gem 'rails', '4.0.2'

# Heroku
group :production do
      gem 'rails_12factor'
end

# Parsing Gems
group :development do
  gem 'nokogiri', '~> 1.6.1'
  gem 'watir-webdriver', '~> 0.6.4'
end

# Testing Gems
group :development, :test do
  gem "rspec-rails", "~> 2.14.1"
  gem "capybara", "~> 2.2.1"
end

# Database Gems
gem 'pg', '~> 0.17.1'
gem 'yaml_db', github: 'jetthoughts/yaml_db', ref: 'fb4b6bd7e12de3cffa93e0a298a1e5253d7e92ba' #Need this host because one on rubygems has a bug
gem "ransack", github: "activerecord-hackery/ransack", branch: "rails-4"

# Front-end Gems
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass'
gem 'kaminari', '~> 0.15.1'
group :development do
  gem 'rails_layout'
end
# Misc. Gems
gem 'uglifier', '>= 1.3.0'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'annotate', '~> 2.6.1'
gem "devise", "~> 3.2.2"

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
