class ScrapFbPros
      require 'koala'
      require 'pry'
      # require 'open-uri'
      # require 'phantomjs'
      # save_from_on_GoogleDrive(tab);


      def column_code_of_hash_keys
          code_col_name_hash                                  ={}
          code_col_name_hash[:event_id]                       =1
          code_col_name_hash[:event_name]                     =2
          code_col_name_hash[:event_start_time]               =3
          code_col_name_hash[:event_end_time]                 =4
          code_col_name_hash[:event_description]              =5

          code_col_name_hash[:event_place_id]                 =6
          code_col_name_hash[:event_place_name]               =7
          code_col_name_hash[:event_place_location_data]      =8
                                                            9==9
          code_col_name_hash[:event_place_city]               =10
          code_col_name_hash[:event_place_country]            =11
          code_col_name_hash[:event_place_latitude]           =12
          code_col_name_hash[:event_place_longitude]          =13
          code_col_name_hash[:event_place_street]             =14
          code_col_name_hash[:event_place_zip]                =15

          code_col_name_hash[:"event_event_times_data"]       =16
          code_col_name_hash[:"event_id"]                     =17
          code_col_name_hash[:"event_start_time"]             =18
          code_col_name_hash[:"event_end_time"]               =19


          code_col_name_hash[:event_paging_data]              =20
          code_col_name_hash[:event_paging_previous]          =21
          code_col_name_hash[:event_paging_next]              =22

          code_col_name_hash[:event_attending_count]          =23
          code_col_name_hash[:event_admins]                   =24
          code_col_name_hash[:event_owner_id]                 =25
          code_col_name_hash[:event_owner_name]               =26
          code_col_name_hash[:event_picture_data_url]         =27
          code_col_name_hash[:event_attending]                =28
          code_col_name_hash[:event_interested]               =29
          return code_col_name_hash
      end


      def save_from_on_GoogleDrive(table_data)

          code_col_name_hash = column_code_of_hash_keys
          session = GoogleDrive::Session.from_config("config.json")
          ws = session.spreadsheet_by_key("1MxgK4pdG5LVvCse6dRTtgjhZEux8rZ6Z9Zk0IlAPYnQ").worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
          for i in 1..table_data.length
              table_data[i-1].each do |key, value|
                 p key
                 y = code_col_name_hash[key]
                 ws[i, y] = table_data[i-1][key]
              end
          end
          ws.save
          ws.reload
      end

      def scrap_events_facebook_groups

        client = FBGraph::Client.new(:client_id => ENV["app_id"],:secret_id => Figaro.env.secret_id ,:token => ENV["token"])
        group = "746919612101754"
        group_page = client.selection.page(group);
        data_scrapping = group_page.fields(:events).info!


        tab = []
        data_scrapping[:events][:data].each do |event|
            if event == nil then break else
               tabh = {}
                tabh[:event_id]          = event[:id]
                tabh[:event_name]        = event[:name]
                tabh[:event_start_time]  = event[:start_time]
                tabh[:event_end_time]    = event[:end_time]
                tabh[:event_description] = event[:description]

                if event[:place] != nil then
                   tabh[:event_place_id]   = event[:place][:id]
                   tabh[:event_place_name] = event[:place][:name]
                        if event[:place][:location] != nil then
                           tabh[:event_place_location_data] = event[:place][:location]
                           tabh[:event_place_city]          = event[:place][:location][:city]
                           tabh[:event_place_country]       = event[:place][:location][:country]
                           tabh[:event_place_latitude]      = event[:place][:location][:latitude]
                           tabh[:event_place_longitude]     = event[:place][:location][:longitude]
                           tabh[:event_place_street]        = event[:place][:location][:street]
                           tabh[:event_place_zip]           = event[:place][:location][:zip]
                        end
                end

                if (tabh[:"event_event_times_data"] = event[:event_times]) == nil then  tab << tabh else
                   tab << tabh                                                                  #sauvegarde event avec ses occurences
                   event[:event_times].each do |event_time|
                       tabh[:"event_id"]                = event_time[:id]
                       tabh[:"event_start_time"]        = event_time[:start_time]
                       tabh[:"event_end_time"]          = event_time[:end_time]
                       tab << tabh                                                              #sauvegarde chaque occurence avec les occurences de l'event principal
                   end

                   #if event[:paging] != nil then
                   #   tabh[:event_paging_data] = event[:paging]
                   #   tabh[:event_paging_previous] = event[:paging][:previous]
                   #   tabh[:event_paging_next] = event[:paging][:next]
                   #end
                   #
                   # tabh[:event_attending_count] = event[:attending_count]
                   # tabh[:event_admins] = event[:admins]
                   # tabh[:event_owner_id] = event[:owner][:id]
                   # tabh[:event_owner_name] = event[:owner][:name]
                   # tabh[:event_picture_data_url] = event[:picture][:data][:url]
                   # tabh[:event_attending] = event[:attending]
                   # tabh[:event_interested] = event[:interested]
                end
            end
        end
        

      def perform
          scrap_events_facebook_groups
      end




           # https://www.facebook.com/events/
           # tab << client.selection.page("746919612101754").methods





           # user = FbGraph2::User.new(ENV['client_id']).authenticate(ENV["token"])
           # user.fetch
           # tab << user.name

           #
           # @fb = MiniFB::Session.new(ENV["app_id"], ENV["secret_id"], ENV["app_token"], ENV["client_id"])
           # user = @fb.methods
           # tab << user
           # # @res = MiniFB.fql(ENV["app_token"], "746919612101754")
           # tab << @fb.get('746919612101754')

           # @graph = Koala::Facebook::API.new
           # profile = @graph.get_object("me")
           # # profile = Figaro.env.token
           # # tab << profile
           #



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
