desc "This task is called by the Heroku scheduler add-on"

task :job => :environment do
  puts "Updating job..."
  JobScrapUrlsProsJob.new.perform
  puts "done."
end

task :the_service_for_url => :environment do
  p "Service for pro websites"
  ScrapUrlsPros.new.perform
  p "Success"
end

task :the_service_for_ids => :environment do
  p "Service for facebook pro ids"
  ScrapUrlsPros.new.perform
  p "Success"
end

task :test => :environment do
  p "hello world !!!"
end
