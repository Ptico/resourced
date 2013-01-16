source 'https://rubygems.org'

# Specify your gem's dependencies in resourced.gemspec
gemspec

group :test do
  gem "rake"
  gem "activerecord", "~> 3.2"
end

platforms :ruby do
  group :test do
    gem "sqlite3"
  end
end

platforms :jruby do
  group :test do
    gem "activerecord-jdbcsqlite3-adapter"
  end
end