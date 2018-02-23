require 'pry'
require 'scrap_urls_pros'  #load 'filename.rb' #every call require/require_relative 'filename' #only once call

class ScrapFbPros
      # require 'open-uri'
      # require 'phantomjs'
      # save_from_on_GoogleDrive(tab);
      # https://www.facebook.com/events/

      attr_accessor :access_token

      def initialize
        hash_bilobaba = { :old_event_id=>"ID event",  :old_event_name=>"Titre events",  :old_event_start_time=>"Debut",  :old_event_end_time=>"Fin",  :old_event_description=>"Description",  :old_event_place_id=>"ID endroit",  :old_event_place_name=>"Nom endroit",  :old_event_place_location_data=>"Information GPS",
                          :old_event_place_city=>"City",  :old_event_place_country=>"Pays",  :old_event_place_latitude=>"Latitude",  :old_event_place_longitude=>"Longitude",  :old_event_place_street=>"street",  :old_event_place_zip=>"zip-code",  :old_event_event_times_data=>"récurrences",  :old_last_date=>"date of scrap",  :old_groupe_id=>"group-id", :old_event_picture_data_url=>"image-url", :origin_base => "origine"}
        hash_sites = { :last_event_id=>"ID event",  :last_event_name=>"Titre events",  :last_event_start_time=>"Debut",  :last_event_end_time=>"Fin",  :last_event_description=>"Description",  :last_event_place_id=>"ID endroit",  :last_event_place_name=>"Nom endroit",  :last_event_place_location_data=>"Information GPS",
                       :last_event_place_city=>"City",  :last_event_place_country=>"Pays",  :last_event_place_latitude=>"Latitude",  :last_event_place_longitude=>"Longitude",  :last_event_place_street=>"street",  :last_event_place_zip=>"zip-code",  :last_event_event_times_data=>"récurrences",  :last_last_date=>"date of scrap",  :last_groupe_id=>"group-id", :last_event_picture_data_url=>"image-url", :origin_base => "origine" }
        @hash_head = hash_sites.merge(hash_bilobaba).merge({:change=>"Change"})
        @tab = []
        @tab << @hash_head

        Evenement.where(:origin_base => 'Facebook').destroy_all
      end


      def get_token
          get_access_token
      end


      def get_all_facebook_groups
          session = ScrapUrlsPros.new.set_google_drive_session
          ws = session.spreadsheet_by_key(ENV["SPEADSHEET_LIENS_ET_IDS"]).worksheets[1]   #cle a changer en fonction du lien url du fichier google drive
          tab_of_urls = []
            for i in 0...(ws.rows.count)    # 1 si en-tête
                tab_of_urls << ws.rows[i][0];
            end
          tab_of_urls
      end



      def compare_datas_in_database(database)
          bilobaba_events = database.where(:origin_base=>"Bilobaba")
          facebook_events = database.where(:origin_base=>"Facebook")

          facebook_events.each do |fb_event|
            	bb_event = bilobaba_events.find_by(:event_id=> fb_event.event_id)
            	if bb_event.nil?  then fb_event.change ="nouveau" else
            		fb_event.change =  (fb_event.attributes.except("id","created_at","updated_at","change","origin_base","last_date") == bb_event.attributes.except("id","created_at","updated_at","change","origin_base","last_date"))? "no change" : "has changed"
            	end
              fb_event.save
          end

          bilobaba_events.each do |bb_event|
            	fb_event = facebook_events.find_by(:event_id=> bb_event.event_id)
            	if fb_event.nil?  then bb_event.change ="supprimé" else bb_event.change ="Toujours Disponible"  end
              bb_event.save
          end
      end



      def scrap_events_facebook_groups(groups)
          # groups = ScrapFbPros.new.get_all_facebook_groups
            @graph = Koala::Facebook::API.new(ENV["token"])
            # @graph.get_object("#{group}?fields=events{photos{images}}")
            # client = FBGraph::Client.new(:client_id => ENV["app_id"],:secret_id => Figaro.env.secret_id ,:token => ENV["token"])
            # group_page = client.selection.page(group);
            # data_scrapping = group_page.fields(:events).info!

            data_scrapping = @graph.get_objects(groups, :fields=> "events{photos{images},description,event_times,id,name,place,start_time,end_time}")
            data_scrapping.each_key do |group|
                data_scrapping[group.to_s][:events.to_s][:data.to_s].each do |event|
                    event_element = Evenement.new
                    if event == nil then break else

                        event_element.last_date         = Time.now
                        event_element.groupe_id         = group
                        event_element.origin_base       = "Facebook"
                        # tabh[:joker]                  =

                        event_element.event_id          = event[:id.to_s]
                        event_element.event_name        = event[:name.to_s]
                        event_element.event_start_time  = event[:start_time.to_s]
                        event_element.event_end_time    = event[:end_time.to_s]
                        event_element.event_description = event[:description.to_s]

                        # tabh[:event_owner_id] = event[:owner][:id]
                        # tabh[:event_owner_name] = event[:owner][:name]
                        # tabh[:event_picture_data_url] = event[:picture.to_s][:data.to_s][:url.to_s]
                        # event_element.event_picture_data_url = event[:photos.to_s][:data.to_s][0][:images.to_s][0]

                        event_element.event_photos_images = event[:photos.to_s][:data.to_s][0][:images.to_s][0]

                        if event[:place.to_s] != nil then
                           event_element.event_place_id   = event[:place.to_s][:id.to_s]
                           event_element.event_place_name = event[:place.to_s][:name.to_s]
                                if event[:place.to_s][:location.to_s] != nil then
                                   event_element.event_place_location_data = event[:place.to_s][:location.to_s]
                                   event_element.event_place_city          = event[:place.to_s][:location.to_s][:city.to_s]
                                   event_element.event_place_country       = event[:place.to_s][:location.to_s][:country.to_s]
                                   event_element.event_place_latitude      = event[:place.to_s][:location.to_s][:latitude.to_s]
                                   event_element.event_place_longitude     = event[:place.to_s][:location.to_s][:longitude.to_s]
                                   event_element.event_place_street        = event[:place.to_s][:location.to_s][:street.to_s]
                                   event_element.event_place_zip           = event[:place.to_s][:location.to_s][:zip.to_s]
                                end
                        end
                        event_element.event_event_times_data = event[:event_times.to_s]
                        if event_element.event_event_times_data == nil then  event_element.save else
                           event_element.save                                                                  #sauvegarde event avec ses occurences
                           event[:event_times.to_s].each do |event_time|
                               event_element = event_element.dup
                               event_element.event_id                = event_time[:id.to_s]
                               event_element.event_start_time        = event_time[:start_time.to_s]
                               event_element.event_end_time          = event_time[:end_time.to_s]
                               event_element.event_event_times_data  = ""
                               event_element.save                                                             #sauvegarde chaque occurence avec les occurences de l'event principal
                           end
                        end
                    end
                end
            end
         @tab += ActiveRecord::Base.connection.exec_query("SELECT evenements.* FROM evenements").to_hash
      end


      # ScrapFbPros.new.get_all_facebook_groups

      def perform
          groups = get_all_facebook_groups                                        #get all group ids
          scrap_events_facebook_groups(groups)                                    #scrap events
          compare_datas_in_database(Evenement)
          @tab
      end

private

      def get_access_token
          @client = FBGraph::Client.new(:client_id => ENV["FIRST_APP_ID"],:secret_id => Figaro.env.secret_id)
            browser = ScrapUrlsPros.new.set_browser_session
            url_of_code = @client.authorization.authorize_url(:redirect_uri => ENV["FACEBOOK_redirect_uri"], :scope => ENV["FACEBOOK_scopes_auths2"]);
            browser.goto(url_of_code);
            sleep 2
            browser.text_field(:id, 'email').set ENV["FACEBOOK_EMAIL"];
            browser.text_field(:id, 'pass').set ENV["FACEBOOK_MDP"];
            sleep 2
            browser.button(:id => "loginbutton").click;
            # if button1.exist? then button1.click
            # if button2.exist? then button2.click
            (browser.url.length < 50)? browser.refresh : code = browser.url;
            code = browser.url;
            code = code[code.index("=")+1..-1]
            begin
              @access_token ||= @client.authorization.process_callback(code, :redirect_uri =>  ENV["FACEBOOK_redirect_uri"])
            rescue => monerreur
              @access_token ||= monerreur.message.scan(/"([^"]*)"/)[1][0];
              @token_type   ||= monerreur.message.scan(/"([^"]*)"/)[3][0]
              @expires_in   ||= monerreur.message.scan(/[0-9]{3,12}/)
            end

            browser.close

            @client.set_token(@access_token)
            @client.selection.me.info!
            ENV["token"] = @access_token.to_s;
            return @access_token.to_s
      end
end
