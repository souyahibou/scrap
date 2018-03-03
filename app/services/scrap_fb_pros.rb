require 'pry'
require 'scrap_urls_pros'  #load 'filename.rb' #every call require/require_relative 'filename' #only once call

class ScrapFbPros
      # https://www.facebook.com/events/

      attr_accessor :access_token

      def initialize
        hash_bilobaba = { :old_event_id=>"ID event",  :old_event_name=>"Titre events",  :old_event_start_time=>"Debut",  :old_event_end_time=>"Fin",  :old_event_description=>"Description",  :old_event_place_id=>"ID endroit",  :old_event_place_name=>"Nom endroit",  :old_event_place_location_data=>"Information GPS",:event_owner_id=>"propriétaire_id", :event_owner_name=>"propriétaire_name", :changements=>"fields_changed",
                          :old_event_place_city=>"City",  :old_event_place_country=>"Pays",  :old_event_place_latitude=>"Latitude",  :old_event_place_longitude=>"Longitude",  :old_event_place_street=>"street",  :old_event_place_zip=>"zip-code",  :old_event_event_times_data=>"récurrences",  :old_last_date=>"date of scrap",  :old_groupe_id=>"group-id", :old_event_picture_data_url=>"image-url", :origin_base => "origine"}
        hash_sites = { :last_event_id=>"ID event",  :last_event_name=>"Titre events",  :last_event_start_time=>"Debut",  :last_event_end_time=>"Fin",  :last_event_description=>"Description",  :last_event_place_id=>"ID endroit",  :last_event_place_name=>"Nom endroit",  :last_event_place_location_data=>"Information GPS",:event_owner_id=>"propriétaire_id", :event_owner_name=>"propriétaire_name", :changements=>"fields_changed",
                       :last_event_place_city=>"City",  :last_event_place_country=>"Pays",  :last_event_place_latitude=>"Latitude",  :last_event_place_longitude=>"Longitude",  :last_event_place_street=>"street",  :last_event_place_zip=>"zip-code",  :last_event_event_times_data=>"récurrences",  :last_last_date=>"date of scrap",  :last_groupe_id=>"group-id", :last_event_picture_data_url=>"image-url", :origin_base => "origine"}

        @hash_head = hash_sites.merge(hash_bilobaba).merge({:change=>"Change"})
        @tab = []
        @tab << @hash_head

        Evenement.where(:origin_base => 'Facebook').destroy_all

        @fields_of_events             = "events{photos{images},description,event_times,id,name,place,start_time,end_time,owner,updated_time}"

        @database_of_events           = Evenement

        @champs_exclus_in_compare     = "id","created_at","updated_at","change","origin_base","last_date","changements"

        @champs_exclus_in_compareInSym = @champs_exclus_in_compare.map{ |elemt| elemt.to_sym }

        @msg_event_changed            = "has changed"
        @msg_event_unchanged          = "no change"
        @msg_event_new_in_fb          = "nouveau"
        @msg_event_deleted_in_fb      = "supprimé"
        @msg_event_undeleted_in_fb    = "Toujours Disponible"

        @data_origin_base_in_bilobaba = "Bilobaba"
        @data_origin_base_in_facebook = "Facebook"

        @access_token                 = ENV["token"]
        # :client_id => ENV["FIRST_APP_ID"]
        # :secret_id => Figaro.env.secret_id
        # :redirect_uri => ENV["FACEBOOK_redirect_uri"]
        # :scope => ENV["FACEBOOK_scopes_auths2"]
        # ENV["FACEBOOK_EMAIL"]
        # ENV["FACEBOOK_MDP"]

        # ENV["LOCAL_OR_HEROKU"]
        # "client_id": ENV["GOOGLE_client_id"]
        # "client_secret": ENV["GOOGLE_client_secret"]
        # "refresh_token": ENV["GOOGLE_refresh_token"]
        # "redirect_uri": ENV["GOOGLE_redirect_uri"]

        # ENV["SPEADSHEET_LIENS_ET_IDS"]
      end





      def get_token
          get_access_token
      end


      def get_all_facebook_groups
          session = ScrapUrlsPros.new.set_google_drive_session
          ws = session.spreadsheet_by_key(ENV["SPEADSHEET_LIENS_ET_IDS"]).worksheets[1]   #cle a changer en fonction du lien url du fichier google drive
          tab_of_urls = []
            for i in 0...(ws.rows.count)    # 1 si en-tête est ajouté
                tab_of_urls << ws.rows[i][0];
            end
          tab_of_urls
      end



      def compare_datas_in_database(database)
          bilobaba_events = database.where(:origin_base=>@data_origin_base_in_bilobaba)
          facebook_events = database.where(:origin_base=>@data_origin_base_in_facebook)

          facebook_events.each do |fb_event|
            	bb_event = bilobaba_events.find_by(:event_id=> fb_event.event_id)
              # binding.pry
            	if bb_event.nil?  then fb_event.change = @msg_event_new_in_fb else
                fb_event.changements = fb_event.diff(bb_event).except(*@champs_exclus_in_compareInSym, :event_owner_name,:event_owner_id) #colonne affichant les champs qui ont changés
            		fb_event.change =  (fb_event.attributes.except(*@champs_exclus_in_compare, "event_owner_name", "event_owner_id") == bb_event.attributes.except(*@champs_exclus_in_compare, "event_owner_name", "event_owner_id"))? @msg_event_unchanged : @msg_event_changed
            	end
              fb_event.save
          end

          bilobaba_events.each do |bb_event|
            	fb_event = facebook_events.find_by(:event_id=> bb_event.event_id)
              if fb_event.nil?  then bb_event.change =@msg_event_deleted_in_fb else
                bb_event.changements = fb_event.diff(bb_event).except(*@champs_exclus_in_compareInSym, :event_owner_name,:event_owner_id) #colonne affichant les champs qui ont changés
                bb_event.change = @msg_event_undeleted_in_fb
              end
              bb_event.save
          end
      end



      def scrap_events_facebook_groups(groups, database)
          # groups = ScrapFbPros.new.get_all_facebook_groups
            @graph = Koala::Facebook::API.new(@access_token)

            data_scrapping = @graph.get_objects(groups, :fields=> @fields_of_events)
            data_scrapping.each_key do |group|
                data_scrapping[group.to_s][:events.to_s][:data.to_s].each do |event|
                    event_element = database.new
                    if event == nil then break else

                        event_element.last_date         = Time.now
                        event_element.groupe_id         = group
                        event_element.origin_base       = @data_origin_base_in_facebook

                        event_element.event_id          = event[:id.to_s]
                        event_element.event_name        = event[:name.to_s]
                        event_element.event_start_time  = event[:start_time.to_s]
                        event_element.event_end_time    = event[:end_time.to_s]
                        event_element.event_description = event[:description.to_s]

                        event_element.event_owner_id    = event[:owner.to_s][:id.to_s]
                        event_element.event_owner_name  = event[:owner.to_s][:name.to_s]
                        # event_element.event_updated_time  = event[:updated_time]
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
                               event_element.event_event_times_data  = event[:event_times.to_s]
                               event_element.save                                                             #sauvegarde chaque occurence avec les occurences de l'event principal
                           end
                        end
                    end
                end
            end
         @tab += ActiveRecord::Base.connection.exec_query("SELECT #{database.table_name}.* FROM #{database.table_name}").to_hash
      end

      # ScrapFbPros.new.get_all_facebook_groups

      def perform
          groups = get_all_facebook_groups                                        #get all group ids
          scrap_events_facebook_groups(groups, @database_of_events)               #scrap events
          compare_datas_in_database(@database_of_events)                          #edit/update the events status
          @tab                                                                    #allow to print the database
      end
################################################################################################################################################################################################
################################################################################################################################################################################################
################################################################################################################################################################################################

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


      #these 2 functions is exactly similar to the function existing in ScrapUrlsPros class by the call: ScrapUrlsPros.new.set_browser_session   &   ScrapUrlsPros.new.set_google_drive_session

      # def new_browser
      #     if ENV["LOCAL_OR_HEROKU"] then
      #         Watir::Browser.new :firefox
      #     else
      #         options = Selenium::WebDriver::Chrome::Options.new
      #         # make a directory for chrome if it doesn't already exist
      #         chrome_dir = File.join Dir.pwd, %w(tmp chrome)
      #         FileUtils.mkdir_p chrome_dir
      #         user_data_dir = "--user-data-dir=#{chrome_dir}"
      #         # add the option for user-data-dir
      #         options.add_argument user_data_dir
      #
      #         # let Selenium know where to look for chrome if we have a hint from
      #         # heroku. chromedriver-helper & chrome seem to work out of the box on osx,
      #         # but not on heroku.
      #         if chrome_bin = ENV["GOOGLE_CHROME_BIN"]
      #            options.add_argument "no-sandbox"
      #            options.binary = chrome_bin
      #            # give a hint to here too
      #            Selenium::WebDriver::Chrome.driver_path = \
      #              "/app/vendor/bundle/bin/chromedriver"
      #         end
      #
      #         # headless!
      #         # keyboard entry wont work until chromedriver 2.31 is released
      #         options.add_argument "window-size=1200x600"
      #         options.add_argument "headless"
      #         options.add_argument "disable-gpu"
      #
      #         # make the browser
      #         Watir::Browser.new :chrome, options: options
      #     end
      # end
      #
      #
      # # ouverture nouvelle session
      # def connexion_to_GoogleDrive type_connex = nil
      #     type_connex ||= "none"
      #     credentials = Google::Auth::UserRefreshCredentials.new(
      #           "client_id": ENV["GOOGLE_client_id"],
      #           "client_secret": ENV["GOOGLE_client_secret"],
      #           "scope": [
      #                     "https://www.googleapis.com/auth/drive",
      #                     "https://spreadsheets.google.com/feeds/"
      #                    ],
      #           "refresh_token": ENV["GOOGLE_refresh_token"],
      #           "redirect_uri": ENV["GOOGLE_redirect_uri"])
      #     auth_url = credentials.authorization_uri
      #
      #     case type_connex
      #          when "first"     then  credentials.code = authorization_code  #si la clé existe et est vide
      #          when "refresh"   then  credentials.refresh_token = refresh_token
      #          when "none"      then  ""
      #          else                   ""
      #     end
      #
      #     credentials.fetch_access_token!
      #     session = GoogleDrive::Session.from_credentials(credentials)
      #     session
      #     # session = GoogleDrive::Session.from_config("config.json")
      # end
end
