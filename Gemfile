source "https://rubygems.org"

# Keep the local build close to GitHub Pages while still running Jekyll 4.x
# explicitly. Use `bundle exec jekyll ...` so these pins are the ones in use.
gem "jekyll", "~> 4.3.0"

# Minima remains installed for compatibility with the original scaffold; custom
# layouts in this repo override the theme's visible templates.
gem "minima", "~> 2.5"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-seo-tag", "~> 2.8"
  gem "jekyll-sitemap", "~> 1.4"
end

# Pin transitive deps that require newer Ruby than the system default,
# so `bundle install` works on Ruby 2.6.x as well as on GitHub Pages CI.
gem "public_suffix", "< 6"
gem "csv"
gem "ffi", "< 1.17"
gem "jekyll-sass-converter", "~> 2.0"

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]
