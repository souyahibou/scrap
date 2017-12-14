class ScrapFbPros
      require 'koala'
      require 'pry'
      # require 'open-uri'
      # require 'phantomjs'

      def perform
           tab = []
           # client = FBGraph::Client.new(:client_id => ENV["app_id"],:secret_id => Figaro.env.secret_id ,:token => ENV["token"])
           # user_info = client.selection.me
           # user_page = client.selection.page("746919612101754");
           # binding.pry
           # tab << user_page.fields(:events).fields(:description).info!
           # # tab << client.selection.page("746919612101754").methods


           # user = FbGraph2::User.new(ENV['client_id']).authenticate(ENV["token"])
           # user.fetch
           # tab << user.name

           #
           # @fb = MiniFB::Session.new(ENV["app_id"], ENV["secret_id"], ENV["app_token"], ENV["client_id"])
           # user = @fb.methods
           # tab << user
           # # @res = MiniFB.fql(ENV["app_token"], "746919612101754")
           # tab << @fb.get('746919612101754')

           @graph = Koala::Facebook::API.new
           profile = @graph.get_object("me")
           # profile = Figaro.env.token
           # tab << profile




           # i=1;
           # j=1;
           # client = Mogli::Client.new(ENV["token"])
           # user = Mogli::User.find("746919612101754",client)
           # tab << user.events[i].description
           # tab << user.events[i].end_time
           # tab << user.events[i].name
           # tab << user.events[i].place.name
           # tab << user.events[i].place.location.city
           # tab << user.events[i].place.location.country
           # tab << user.events[i].place.location.latitude
           # tab << user.events[i].place.location.longitude
           # tab << user.events[i].place.location.street
           # tab << user.events[i].place.location.zip
           # tab << user.events[i].place.id
           # tab << user.events[i].start_time
           # tab << user.events[i].event_times.id
           # tab << user.events[i].event_times[j].id
           # tab << user.events[i].event_times[j].start_time
           # tab << user.events[i].event_times[j].end_time
           # tab << user.events[i].paging.previous
           # tab << user.events[i].paging.next
           # tab << user.events[i].id
           return tab

      end
end
