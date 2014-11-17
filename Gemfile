source 'https://rubygems.org'
ruby '2.1.4'
gem 'rails', '~>4.1.6'

# Heroku
group :production do
      gem 'rails_12factor'
      gem 'unicorn'
end

# Parsing Gems
group :development do
  gem 'nokogiri', '~> 1.6.1'
  gem 'watir-webdriver', '~> 0.6.11'
end

# Testing Gems
group :development, :test do
  gem "rspec-rails", "~> 2.14.1"
  gem "capybara", "~> 2.2.1"
end

# Database Gems
gem 'pg', '~> 0.17.1'
gem "polyamorous", :github => "activerecord-hackery/polyamorous"
gem "ransack", github: "activerecord-hackery/ransack", branch: "rails-4.1"
gem "bullet", group: "development"

# Front-end Gems
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass'
gem 'autoprefixer-rails'
gem 'kaminari', '~> 0.15.1'
gem 'twitter-typeahead-rails'
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
gem "imgkit", "~> 1.4.0"

gem 'rack-mini-profiler'
gem 'dalli'
group :development do
  gem 'pry'
  gem 'pry-rails'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
