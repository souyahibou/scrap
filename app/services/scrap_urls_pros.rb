require 'open-uri'
class ScrapUrlsPros #< Thor

      def scrap_links_for_all_webpages(tab_of_pages)                                              #scrap et enregistre les données(pages) de tous les sites dan sun array :1ere colonnes les sites,2e colonne les datas(pages)
         block_text = [];
         tab_for_all_data =[{:link => "Site Professeur", :scrap => "Données de Page", :methode => "Gemme", :date => "Date", :change => "Etat"}];
         tab_of_hard_pages = {:justdance => 'http://www.justdancewithlife.com/calendrier-calendar/'}

         tab_of_pages.each do |page_pro|
               next if page_pro == tab_of_hard_pages[:justdance]                 #à supprimer à terme
               methode = "Nokogiri"
               block_text = scrap_soft_link(page_pro);
               block_text = (( block_text != "" )? block_text : (  methode = "Watir"; scrap_hard_links(page_pro) ) );   #attention à l'ordre des instruction
               tab_for_all_data << {:link => page_pro, :scrap => block_text, :methode => methode, :date => Time.now}
         end
               block_text = scrap_justdancewithlife_link(tab_of_hard_pages[:justdance]).join(' END AND BEGIN BETWEEN PAGES ').delete(" \t\r\n");
               tab_for_all_data << {:link => tab_of_hard_pages[:justdance], :scrap => block_text, :methode => "Unique with Watir", :date => Time.now}

         return tab_for_all_data;
      end




      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # #Interaction avec base de données//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      #sauvegarde dans google drive
      def save_from_on_GoogleDrive(table_data)
          session = GoogleDrive::Session.from_config("config.json")
          ws = session.spreadsheet_by_key(ENV["SPEADSHEET_SCRAPPING_URLS"]).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
           for i in 0...table_data.length
             y = 1;
             table_data[i].each do |key, value|
                 ws[i+1, y] = table_data[i][key]
                 y += 1;
             end
           end
          ws.save
          ws.reload
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      def comp_data_in_SpreadSheet(table_data)                                           #compare la table de données avec la table de données déja existante (enregistrée au format CSV)
          session = GoogleDrive::Session.from_config("config.json")
          ws = session.spreadsheet_by_key(ENV["SPEADSHEET_SCRAPPING_URLS"]).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
          for i in 0...table_data.length
              table_data[i][:change] = ((ws.rows[i][1] <=> table_data[i][:scrap])==0)? "No change" : "Yes"; #compare les datas de pages
          end
          return table_data;
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      def key_to_json_file
          tempHash = {
            "type": ENV["type"],
            "project_id":  ENV["project_id"],
            "private_key_id":  ENV["private_key_id"],
            "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC1f6/GQYNrh2ab\n79exTLan/8zBU1LQ9Rhpw8co7ybaS8G472p9Kl8HH7G1yxraSs9OjRDBrHBJagr/\nnhPuHgxtqe9AXARj8MVrKU9pSRaMU9Li7J8FlENQzN5RY138Ew1pVFxmmRuV2lcT\npFESQ+iwA+4FEPcsgXTJzo0Bgvvoxmg5MYMPSTPZLAnWVfPj2uLNJzQ5C8YVr1Hk\nfoquKSNcvwIzN9ljnBY2tb14nyP9NMR73a39BgTgdAMjzD0pwhtTKl+vjsIpvQGB\nNn9nSYvd9f4e5l7Y728n+WXoHfqAPocoLfO8NrFAoftqAGP8Ixk0D22XzzLQ/F4+\nDDPH7XIpAgMBAAECggEAHrAVP1dKaj79mXYnKSJIbAVzUGjPQud+Fjv1C7XMAvL2\nMVfB0KH+aUzxlkReKPSnMqflYmnOnosgivHmesd34H7wJhio4WEPcDwO4kVqW5W8\nvYO2q5HTA/Fv0aEUfg+Wn+2UpgBTSrYdLQQGdSkoScKQVyj0MgE9hvW2n7/O6h+B\nCGH6NQdDw9vyR2tXaQdKNwI62/0oTJ5DZAD340A2l3p8VqJsmRn+Lw/7I6/3hlYG\nhux9WtAMOVl7pvsRPO94spjLe+Rdo0v9lKJHWBJOBnt3jtRCJ1IZk49oaqOtHFrp\n8Fp/TVRssWNaMu5LIon1H1drnWgFly5KT3AKNOuoJQKBgQDeSeA8aWbHySQZAAck\nLKCMrq2R03AxjI6gJhPk7W/IFjrrFi+g/A496+biukZX6ZDDjUrF3DiKk82ZZJbw\ne5NIYCelg8qpeykjJxUjjbMnCJQHAfbc2hvkSKETqRDotzZ8/PbAigCmVmmTKAj9\nMjLl1hzf8hiLxC7sTyMQyCLBWwKBgQDRBjBXU/OjaeI7723df9ucLq7R0k4cSrEE\nHx2mI/h0Elk3UM9/gI+AboVWWaPgMS0ZAYpr8dNkIoSFgWpKt3Qp1irO8otYGzzd\n8eUD6dBJamf+f7/qtMbQuC+7A/m9BWXgL2kEZO16EN61mUKBryMagG1YPPOY6BJ2\n3EJAbs2NywKBgB41F93dzPPVZ6xmDpJh5id4DWpFu3dgTHmC8y0m/wvHyZXs2+ga\nmKzdg/DHs4t62AtbBhBBTwW19DimLMTdZjRtrLWXZVEGxZ5bT0oXlYL2bXdOUwfM\nNAIfxJPxY7TcQPFXRwj/N/tivtIanK4bxkLph97+/UrxDBdc4b0EFYUFAoGBALp3\nKui8m7xL2OZe0UOnq+HIQ2wqkEPs3b0vhOORczMYqz4NeQ3lQh7weUJu9SIqvHBy\nT2m8cTgDEvWGXawJvDcWN1omROh0Y/gaspKrIoRbyCnhDPP0EOhhZzMOeNuG1TsJ\nEEY7Qx6BriuSbSIDeu1JZEIzHZxqaw5drzyLnBPBAoGBAJab8nIRU06Oqks4VdEl\nfn1GjxoZeXbPAWy8+127ssvY7uc0tLg25N4XwXyNzHtxGOd1iUbqdaTofRb5guJO\na+wD+wuK3mzrGqZ9dIx8tY1vezGNMFBeYSiO/rrrh5Gw0IvpdIlul61HgZasOioK\ntwjxmlc4z/c4odysuTa1QUeC\n-----END PRIVATE KEY-----\n",
            "client_email":  ENV["client_email"],
            "client_id":  ENV["client_id"],
            "auth_uri": ENV["auth_uri"],
            "token_uri": ENV["token_uri"],
            "auth_provider_x509_cert_url": ENV["auth_provider_x509_cert_url"],
            "client_x509_cert_url": ENV["client_x509_cert_url"]
          }

          File.open("new.json","w") do |f|
            f.write(tempHash.to_json)
            # f.write(JSON.pretty_generate(tempHash))
          end
          return "new.json"
      end


      def get_all_professors_urls
        session = GoogleDrive::Session.from_config("config.json")
        ws = session.spreadsheet_by_key(ENV["SPEADSHEET_LIENS_ET_IDS"]).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
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
          block_text = page.css('html').text.delete(" \t\r\n");
          return block_text;
      end


      def scrap_hard_links(link)                                                      #utilise une copy de la page via la gem watir au lieu de Nokogiri


          browser = new_browser
          browser.goto(link)
            # sleep 2
          res = browser.body.text
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
              copy_of_pages << copy_page.length
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
end
