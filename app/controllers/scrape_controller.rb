class ScrapeController < ApplicationController
  def scrape
      scraper = WebScraper.new
      scraper.start_scrape
  end
end