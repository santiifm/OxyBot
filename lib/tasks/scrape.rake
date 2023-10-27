namespace :scrape do
  desc 'Run the web scraper'
    task :run => :environment do
      scraper = WebScraper.new
      begin
        scraper.start_scrape
      rescue Errno::ECONNREFUSED
        # Cuando se usa @driver.quit tira este error y me ensucia la consola asique ahora te saluda el programa :)
        puts 'Chau!'
      end
    end
end
