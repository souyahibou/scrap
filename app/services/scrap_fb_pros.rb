class ScrapFbPros
      require 'pry'
      # require 'open-uri'
      # require 'phantomjs'
      # save_from_on_GoogleDrive(tab);
      # https://www.facebook.com/events/


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

          code_col_name_hash[:change]                         =9

          code_col_name_hash[:event_place_city]               =10
          code_col_name_hash[:event_place_country]            =11
          code_col_name_hash[:event_place_latitude]           =12
          code_col_name_hash[:event_place_longitude]          =13
          code_col_name_hash[:event_place_street]             =14
          code_col_name_hash[:event_place_zip]                =15

          code_col_name_hash[:"event_event_times_data"]       =16
          # code_col_name_hash[:"event_id"]                   =17
          # code_col_name_hash[:"event_start_time"]           =18
          # code_col_name_hash[:"event_end_time"]             =19


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
          code_col_name_hash[:event_photos_images]            =30
          return code_col_name_hash
      end

      def get_all_facebook_groups
          session = GoogleDrive::Session.from_config("config.json")
          ws = session.spreadsheet_by_key(ENV["SPEADSHEET_LIENS_ET_IDS"]).worksheets[1]   #cle a changer en fonction du lien url du fichier google drive
          tab_of_urls = []
            for i in 0...(ws.rows.count)    # 1 si en-tête
                tab_of_urls << ws.rows[i][0]
            end
          return tab_of_urls
      end



      def comp_data_in_SpreadSheet(table_data)                                           #compare la table de données avec la table de données déja existante (enregistrée au format CSV)
          session = GoogleDrive::Session.from_config("config.json")
          ws = session.spreadsheet_by_key( ENV["SPREADSHEET_SCRAPPING_FB_EVENTS"] ).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
          for i in 0...table_data.length
              table_data[i][:change] = ( ( table_data[i].all? {|key, value| ws[i+2, column_code_of_hash_keys[key]] <=> table_data[i][key]} )== false)? "No change" : "Yes";
              # table_data[i-1][:change] = ((ws[i, 2] <=> table_data[i-1].each do |key, value|)==0)? "No change" : "Yes"; #compare les links
          end
          return table_data;
      end


      def save_from_on_GoogleDrive(table_data)

          code_col_name_hash = column_code_of_hash_keys
          session = GoogleDrive::Session.from_config("config.json")
          ws = session.spreadsheet_by_key( ENV["SPREADSHEET_SCRAPPING_FB_EVENTS"] ).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
          for i in 0...table_data.length
              table_data[i].each do |key, value|
                 y = code_col_name_hash[key]
                 ws[i+2, y] = table_data[i][key]
              end
          end
          ws.save
          ws.reload
      end




      def scrap_events_facebook_groups(group)
            client = FBGraph::Client.new(:client_id => ENV["app_id"],:secret_id => Figaro.env.secret_id ,:token => ENV["token"])
            group_page = client.selection.page(group);
            data_scrapping = group_page.fields(:events).info!


            tab = []
            data_scrapping[:events][:data].each do |event|
                tabh = {}
                if event == nil then break else

                    tabh[:event_id]          = event[:id]
                    tabh[:event_name]        = event[:name]
                    tabh[:event_start_time]  = event[:start_time]
                    tabh[:event_end_time]    = event[:end_time]
                    tabh[:event_description] = event[:description]

                    tabh[:event_owner_id] = event[:owner][:id]
                    tabh[:event_owner_name] = event[:owner][:name]
                    tabh[:event_picture_data_url] = event[:picture][:data][:url]

                    tabh[:event_photos_images] = event[:photos][:images][0]

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
                    tabh[:"event_event_times_data"] = event[:event_times]
                    if tabh[:"event_event_times_data"] == nil then  tab << tabh.clone else
                       tab << tabh.clone                                                                  #sauvegarde event avec ses occurences
                       event[:event_times].each do |event_time|
                           tabh[:event_id]                = event_time[:id]
                           tabh[:event_start_time]        = event_time[:start_time]
                           tabh[:"event_end_time"]        = event_time[:end_time]
                           tabh[:"event_event_times_data"]= ""
                           tab << tabh.clone                                                              #sauvegarde chaque occurence avec les occurences de l'event principal
                       end

                       #if event[:paging] != nil then
                       #   tabh[:event_paging_data] = event[:paging]
                       #   tabh[:event_paging_previous] = event[:paging][:previous]
                       #   tabh[:event_paging_next] = event[:paging][:next]
                       #end
                       #
                       # tabh[:event_attending_count] = event[:attending_count]
                       # tabh[:event_admins] = event[:admins]

                       # tabh[:event_attending] = event[:attending]
                       # tabh[:event_interested] = event[:interested] je dois
                    end
                end
            end
            return tab
      end


# ScrapFbPros.new.get_all_facebook_groups

      def perform
          tab = [];                                                               #all events
          groups = get_all_facebook_groups                                        #get all group ids
          groups.each do |group|
              tab += scrap_events_facebook_groups(group)                          #scrap events
          end
          tab = comp_data_in_SpreadSheet(tab)                                     #test if change in speadsheet
          save_from_on_GoogleDrive(tab)                                           #save in speadsheet
          return tab
      end
end
