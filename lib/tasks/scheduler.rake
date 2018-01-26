desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  puts "Updating job..."
  JobScrapUrlsProsJob.new.perform
  puts "done."
end

task :test => :environment do
  p "hello world !!!"
end
