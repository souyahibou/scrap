desc "This task is called by the Heroku scheduler add-on"

task :job => :environment do
  puts "Updating job..."
  JobScrapUrlsProsJob.new.perform
  puts "done."
end


task :test => :environment do
  p "hello world !!!"
end

task :service_for_url => :environment do
  p "Service for pro websites"
  ScrapUrlsPros.new.perform
  p "Success"
end

task :service_for_ids => :environment do
  p "Service for facebook pro ids"
  ScrapFbPros.new.perform
  p "Success"
end


task :first_connexion => :environment do
  p "Service for pro websites"
  ScrapUrlsPros.new.set_first_connexion
  ScrapFbPros.new.get_access_token
  p "Success"
end
