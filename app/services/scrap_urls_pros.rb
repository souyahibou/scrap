require "googleauth"


class ScrapUrlsPros #< Thor

      # public
      #   scrap_links_for_all_webpages
      #   scrap_soft_link(link)
      #   scrap_justdancewithlife_link(link)
      #
      #   get_all_professors_urls
      #   comp_data_in_SpreadSheet(table_data)
      #   save_from_on_GoogleDrive(table_data)
      #
      # private
      #   new_browser
      #   connexion_to_GoogleDrive(type_connex)
      #   column_code_of_hash_keys

      attr_accessor :spreadsheet_fb_events_key, :spreadsheet_urls_key,  :spreadsheet_liens_et_ids_key, :get_code_col_name_hash

      def set_google_drive_session
          connexion_to_GoogleDrive
      end


      def set_browser_session
          new_browser
      end


      def set_first_connexion     #activate_first_connexion_GoogleDrive
          connexion_to_GoogleDrive("first")
      end


      def set_refresh_connexion     #activate_first_connexion_GoogleDrive
          connexion_to_GoogleDrive("refresh")
      end


      def initialize
          @spreadsheet_fb_events_key = ENV["SPREADSHEET_SCRAPPING_FB_EVENTS"]
          @spreadsheet_urls_key = ENV["SPEADSHEET_SCRAPPING_URLS"]
          @spreadsheet_liens_et_ids_key = ENV["SPEADSHEET_LIENS_ET_IDS"]
          @get_code_col_name_hash = column_code_of_hash_keys
          hash_bilobaba    = {:old_scrap => "Données de Page Bilobaba",  :old_methode => "Gemme Bilobaba",  :old_date => "Date Bilobaba"}
          hash_sites       = {:last_scrap => "Données de Page sites", :last_methode => "Gemme sites", :last_date => "Date sites"}
          @hash_head        = {:link => "Site Professeur"}.merge(hash_bilobaba).merge(hash_sites).merge({ :change => "Etat", :last_modif => "Dernière modif"})

      end

      def scrap_links_for_all_webpages(tab_of_pages)                                              #scrap et enregistre les données(pages) de tous les sites dan sun array :1ere colonnes les sites,2e colonne les datas(pages)
         block_text       = [];
         tab_for_all_data = [@hash_head];
         tab_of_hard_pages = {:justdance => 'http://www.justdancewithlife.com/calendrier-calendar/'}

         tab_of_pages.each do |page_pro|
               next if page_pro == tab_of_hard_pages[:justdance]                 #à supprimer à terme
               methode = "Nokogiri"
               block_text = scrap_soft_link(page_pro);
               block_text = (( block_text.length > 100 )? block_text : (  methode = "Watir"; scrap_hard_links(page_pro) ) );   #attention à l'ordre des instruction    #bien regler la règle pour le choix de watir
               tab_for_all_data << {:link => page_pro, :last_scrap => block_text.to_s, :last_methode => methode, :last_date => Time.now}
         end
               block_text = scrap_justdancewithlife_link(tab_of_hard_pages[:justdance]).join(' END AND BEGIN BETWEEN PAGES ').gsub(/([ \t\r\n])/,"|").gsub(/[\|]+/,"|")#.delete(" \t\r\n");
               tab_for_all_data << {:link => tab_of_hard_pages[:justdance], :last_scrap => block_text, :last_methode => "Unique with Watir", :last_date => Time.now}

         return tab_for_all_data;
      end



      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # #Interaction avec base de données//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      #sauvegarde dans google drive
      def save_from_on_GoogleDrive(table_data)
          session = connexion_to_GoogleDrive
          ws = session.spreadsheet_by_key(@spreadsheet_urls_key).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
          y = get_code_col_name_hash

          for i in 0...table_data.length
             if  table_data[i][:change] ==  "Yes" || table_data[i][:change] == "Etat"
                 table_data[i].each { |key, value|  ws[i+1,y[key]] = table_data[i][key] }
              else
                  ws[i+1,y[:change]] = table_data[i][:change]                     #la ligne 1 correspond aux données d'en-tête de colonnes
             end
          end
          ws.save
          ws.reload
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      def comp_data_in_SpreadSheet(table_data)                                           #compare la table de données avec la table de données déja existante (enregistrée au format CSV)
          y = get_code_col_name_hash[:old_scrap]                                    #diff between ws.rows[i][y] and ws[i,y]
          session = connexion_to_GoogleDrive
          ws = session.spreadsheet_by_key(@spreadsheet_urls_key).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
          for i in 2..table_data.length
                  table_data[i-1][:change] = ((ws[i, y] <=> table_data[i-1][:last_scrap])==0)? "No change" : (table_data[i-1][:last_modif] = Differ.diff(ws[i, y],table_data[i-1][:last_scrap],'|').to_s.scan(/{.[^{}]*}/)  ;"Yes"); #compare les datas de pages
          end
          return table_data;
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      def get_all_professors_urls
        session = connexion_to_GoogleDrive
        ws = session.spreadsheet_by_key(@spreadsheet_liens_et_ids_key).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
        tab_of_urls = []
          for i in 0...(ws.rows.count)    #1 i en-tête
              tab_of_urls << ws.rows[i][0]
          end
        return tab_of_urls
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # #Scrapping spéciaux////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      def scrap_soft_link(link)                                                       #scrap general
          page = Nokogiri::HTML(open(link));
          # block_text = page.css('html').text.delete(" \t\r\n");
          block_text = page.xpath('//text()').select { |e| Nokogiri::XML::Text === e}.reject { |e| Nokogiri::XML::CDATA === e}.map{ |e| e.content}.join("   ").gsub(/([ \t\r\n])/,"|").gsub(/[\|]+/,"|");
          return block_text;
      end


      def scrap_hard_links(link)                                                      #utilise une copy de la page via la gem watir au lieu de Nokogiri

          browser = new_browser
          browser.goto(link)
            sleep 2
          res = browser.body.text.gsub(/([ \t\r\n])/,"|").gsub(/[\|]+/,"|")
          browser.close;

          return res;
      end


      def scrap_justdancewithlife_link(link)                                          #scrap particulier
          copy_of_pages=[];

          browser = new_browser;
          browser.goto(link);
          browser.element(:xpath => "/html/body/div[1]/div/div/main/article/div/div/div[1]/div[2]/div/div/div/div/div/div/div/div/div/div/div[2]/div[2]/div[1]/div[1]/a").click;  #ouvre le dropdown choix du format(Agenda/Month)
          browser.element(:xpath => "//*[@id='ai1ec-view-agenda']").click;     #Selection de "Agenda"
          5.times do
              p browser.element(:xpath => "/html/body/div[1]/div/div/main/article/div/div/div[1]/div[2]/div/div/div/div/div/div/div/div/div/div/div[2]/div[2]/div[1]/div[2]/div").text #mois selected
              copy_page = browser.body.text
              copy_of_pages << copy_page
              browser.element(:xpath => "/html/body/div[1]/div/div/main/article/div/div/div[1]/div[2]/div/div/div/div/div/div/div/div/div/div/div[2]/div[2]/div[1]/div[2]/div[1]/a[3]").fire_event('click')   #pour aller page suivante en format agenda
              sleep 3;
          end
          browser.close;
          return  copy_of_pages;   #la derniere page comprends les données des pages précédentes.(code pouvant etre simplifié) a revérifier
      end


      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # #Exécution code principal////////////////////////////////////////////////#ouvre la dernière data save , reprend en arg les dateas scrapés et les compares.//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      def perform
         tab = [];
         list_urls = get_all_professors_urls
         tab = scrap_links_for_all_webpages(list_urls);
         comp_data_in_SpreadSheet(tab);
         save_from_on_GoogleDrive(tab);
         return tab;
      end

      private
          # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          # #Configuration nouveau navigateur////////////////////////////////////////////////.//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          def new_browser
              if ENV["LOCAL_OR_HEROKU"] then
                  Watir::Browser.new :firefox
              else
                  options = Selenium::WebDriver::Chrome::Options.new
                  # make a directory for chrome if it doesn't already exist
                  chrome_dir = File.join Dir.pwd, %w(tmp chrome)
                  FileUtils.mkdir_p chrome_dir
                  user_data_dir = "--user-data-dir=#{chrome_dir}"
                  # add the option for user-data-dir
                  options.add_argument user_data_dir

                  # let Selenium know where to look for chrome if we have a hint from
                  # heroku. chromedriver-helper & chrome seem to work out of the box on osx,
                  # but not on heroku.
                  if chrome_bin = ENV["GOOGLE_CHROME_BIN"]
                     options.add_argument "no-sandbox"
                     options.binary = chrome_bin
                     # give a hint to here too
                     Selenium::WebDriver::Chrome.driver_path = \
                       "/app/vendor/bundle/bin/chromedriver"
                  end

                  # headless!
                  # keyboard entry wont work until chromedriver 2.31 is released
                  options.add_argument "window-size=1200x600"
                  options.add_argument "headless"
                  options.add_argument "disable-gpu"

                  # make the browser
                  Watir::Browser.new :chrome, options: options
              end
          end


          # ouverture nouvelle session
          def connexion_to_GoogleDrive type_connex = nil
              type_connex ||= "none"
              credentials = Google::Auth::UserRefreshCredentials.new(
                    "client_id": ENV["GOOGLE_client_id"],
                    "client_secret": ENV["GOOGLE_client_secret"],
                    "scope": [
                              "https://www.googleapis.com/auth/drive",
                              "https://spreadsheets.google.com/feeds/"
                             ],
                    "refresh_token": ENV["GOOGLE_refresh_token"],
                    "redirect_uri": ENV["GOOGLE_redirect_uri"])
              auth_url = credentials.authorization_uri

              case type_connex
                   when "first"     then  credentials.code = authorization_code  #si la clé existe et est vide
                   when "refresh"   then  credentials.refresh_token = refresh_token
                   when "none"      then  ""
                   else                   ""
              end

              credentials.fetch_access_token!
              session = GoogleDrive::Session.from_credentials(credentials)
              session
              # session = GoogleDrive::Session.from_config("config.json")
          end

          def column_code_of_hash_keys
              code_col_name_hash                              ={}
              code_col_name_hash[:link]                       =1
              code_col_name_hash[:old_scrap]                  =2
              code_col_name_hash[:old_methode]                =3
              code_col_name_hash[:old_date]                   =4
              code_col_name_hash[:last_scrap]                 =5
              code_col_name_hash[:last_methode]               =6
              code_col_name_hash[:last_date]                  =7
              code_col_name_hash[:change]                     =8
              code_col_name_hash[:last_modif]                 =9

              return code_col_name_hash
          end
end
