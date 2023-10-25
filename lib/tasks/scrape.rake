namespace :scrape do
  desc 'Run the web scraper'
  task :run => :environment do
      scraper = WebScraper.new
      scraper.start_scrape
  end
end