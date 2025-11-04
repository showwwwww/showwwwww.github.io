require 'mongo'
require 'json'

Jekyll::Hooks.register :site, :after_init do |site|
  # Load articles from MongoDB during build
  client = Mongo::Client.new(['localhost:27017'], database: 'blog')
  articles = client[:articles].find({ is_published: true })
                             .sort({ published_date: -1 })
                             .limit(10)
  
  # Make articles available to Jekyll
  site.config['mongodb_articles'] = articles.to_a
end
