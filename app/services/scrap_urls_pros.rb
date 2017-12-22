class ScrapUrlsPros
      require 'open-uri'

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
               block_text = scrap_justdancewithlife_link('http://www.justdancewithlife.com/calendrier-calendar/').delete(" \t\r\n");
               tab_for_all_data << {:link => tab_of_hard_pages[:justdance], :scrap => block_text, :methode => "Watir", :date => Time.now}

         return tab_for_all_data;
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # #Interaction avec base de données//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


      def save_data_in_CSV_file(table_data)                                           #sauvegarde la table de données dans un fichier CSV
         CSV.open("the_scrap_2.csv", "w") do |csv|
           for i in 1..table_data.length
             csv << [ table_data[i-1][:link], table_data[i-1][:scrap] ];
           end
         end
      end



      def comp_data_in_CSV_file(table_data)                                           #compare la table de données avec la table de données déja existante (enregistrée au format CSV)
          arr_of_arrs = CSV.read("the_scrap_2.csv");
          for i in 1..arr_of_arrs.length
              table_data[i-1][:change] = ((arr_of_arrs[i-1][1] <=> table_data[i-1][:scrap])==0)? "no chng" : table_data[i-1][:link]; #compare les scraps
          end
          return table_data;
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      #sauvegarde dans google drive
      def save_from_on_GoogleDrive(table_data)
          session = GoogleDrive::Session.from_config("config.json")
          ws = session.spreadsheet_by_key(ENV["SPEADSHEET_SCRAPPING_URLS"]).worksheets[0]   #cle a changer en fonction du lien url du fichier google drive
           for i in 1..table_data.length
             y = 1;
             table_data[i-1].each do |key, value|
                 ws[i, y] = table_data[i-1][key]
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
          for i in 1..table_data.length
              table_data[i-1][:change] = ((ws[i, 2] <=> table_data[i-1][:scrap])==0)? "No change" : "Yes"; #compare les datas de pages
          end
          return table_data;
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
          browser = Watir::Browser.new (:firefox)
          browser.goto(link)
          res = browser.body.text
          browser.close;
          return res;
      end


      def scrap_justdancewithlife_link(link)                                          #scrap particulier
          copy_of_pages=[];
          fin = 13;
          browser = Watir::Browser.new(:firefox);
          browser.goto(link);
          browser.element(:xpath => "/html/body/div[1]/div/div/main/article/div/div/div[1]/div[2]/div/div/div/div/div/div/div/div/div/div/div[2]/div[2]/div[1]/div[1]/a").click;
          browser.element(:xpath => "//*[@id='ai1ec-view-agenda']").click;

          while fin > 1 do
              copy_page = browser.body.text
              ( copy_of_pages[-1] != copy_page )? ( copy_of_pages << copy_page ; fin -= 1 ) : fin = 1 ;
              browser.element(:xpath => "/html/body/div[1]/div/div/main/article/div/div/div[1]/div[2]/div/div/div/div/div/div/div/div/div/div/div[2]/div[2]/div[1]/div[2]/div[1]/a[3]").click;
              sleep 2;
          end
          browser.close;
          return  copy_page;   #la derniere page comprends les données des pages précédentes.(code pouvant etre simplifié)
      end

      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # #Exécution code principal//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      # ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      def perform
         tab = [];
         list_urls = get_all_professors_urls
         tab = scrap_links_for_all_webpages(list_urls);
         binding.pry
         comp_data_in_SpreadSheet(tab);          #ouvre la dernière data save , reprend en arg les dateas scrapés et les compares.
         save_from_on_GoogleDrive(tab);
         return tab;
      end
end
