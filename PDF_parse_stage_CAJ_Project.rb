reader = PDF::Reader.new("CAJ.pdf");

texte_of_all_pages = []
table_stage =[]
table_erreur=[]
table_erreur2=[]
blocs = blocs


#extraction du text pertinent du text brut
reader.pages.each do |page_num|
    texte_utile               = page_num.raw_content.scan(/Td.*Tj/).join
    texte_utile.force_encoding('ISO-8859-1')
    texte_reformated          = texte_utile.encode('UTF-8').gsub(/\\\(/,'(').gsub(/\\\)/,')')
    texte_reformated_filtered = texte_reformated.remove("Tj", "Td")
    texte_of_all_pages       << texte_reformated_filtered
end

texte_of_all_pages_united = texte_of_all_pages.join
#File.open('CAJparse', "w") {|file| file.puts stop}

#découpage du fichier par pages
stages = texte_of_all_pages_united.scan(/(\(Le Stage \))(.+?)(\(Fax.{1,20}\(Page .{1,3}\))|(\((?:[a-zA-Z_][^(0-9)]|\s){5,38}\))(?:\s{1,5})(\(Page .{1,3}\))/)

# scrap de tous les stages
stages.each do |stage|
    begin
        bloc = stage.join
        2.times{  left = bloc.partition(/(\(Page \d+?\))(?!$)/)[0];   right = bloc.partition(/(\(Page \d+?\))(?!$)/)[2];    bloc = left + right  }  #retire le texte "page (...)" pour les stage s'étalant sur deux ou trois pages
        blocs = (bloc).scan(/\(Personne à contacter \).+?\(Fax.{1,20}\(Page .{1,3}\)|\((?:\w\D|\s){5,35}\)\s{1,5}\(Page .{1,3}\)|\(Employeur : \).+?\(Adresse militaire : \)  \( .*? \)|\(Le Stage \).+?\(Lieu \)|\((?:[a-zA-Z_][^(0-9)]|\s){5,38}\)/) # retire (Page .{1,3} sauf si dernier) et groupe les blocs et page catégories
        (blocs.length == 1)? (table_stage << {:domaine => blocs[0]}) : true
        next if (blocs.length == 1)
    #bloc stage
        bloc_stage = blocs[0]
        bloc_lieu = blocs[1]
        bloc_contact = blocs[2]

        extraction = Proc.new do |bloc_text,debut,fin,offset|              #procedure utilisé pour simplifier/optimiser le code
            (offset==nil)? long_deb = debut.length : long_deb = 0
            (fin.class == Integer)? bloc_text[bloc_text.index(debut)+long_deb..fin] : bloc_text[bloc_text.index(debut)+long_deb..bloc_text.index(fin)-1]
        end

        before_demandé       = extraction.call(bloc_stage, '(Le Stage )'        ,'(Niveau demandé : )')
        niveau_demandé       = extraction.call(bloc_stage, '(Niveau demandé : )','(Nombre de places : )')
        nombre_de_places     = extraction.call(bloc_stage, '(Nombre de places : )','(Descriptif : )',true)
        descriptif           = extraction.call(bloc_stage, '(Descriptif : )'    ,'(Logement : )')
        logement             = extraction.call(bloc_stage, '(Logement : )'      ,'(Restauration : )')
        restauration         = extraction.call(bloc_stage, '(Restauration : )'  ,'(Période : )')
        période              = extraction.call(bloc_stage, '(Période : )'       ,'(Précision durée: )',true)
        précision_durée      = extraction.call(bloc_stage, '(Précision durée: )','(Autres commentaires : )')
        autres_commentaires  = extraction.call(bloc_stage, '(Autres commentaires : )',-8)

        stage_regroup_elmt = before_demandé + nombre_de_places + période        #pour les style mais peuvent être intégre comme les autre
        stage_cut_by_specs = stage_regroup_elmt.scan( /\((.+?)\)/)
        stage_keys_into_str = stage_cut_by_specs.map{|a| a[0].to_s}
        hash_stage = Hash[*stage_keys_into_str].merge({"Niveau demandé : "=>niveau_demandé, "Descriptif : "=> descriptif, "Autres commentaires : "=>autres_commentaires, "Logement :"=>logement, "Restauration :"=>restauration, "Précision durée:"=>précision_durée })
    #bloc lieu
    ##---------------------------------------------------------------------------------------------------------------------------------------------------
        employeur         =  extraction.call(bloc_lieu, '(Employeur : )'      ,'(Localisation : )').scan( /\((.+)\)/).join
        localisation      =  extraction.call(bloc_lieu, '(Localisation : )'   ,'(Etablissement : )').scan( /\((.+)\)/).join
        etablissement     =  extraction.call(bloc_lieu, '(Etablissement : )'  ,'(Adresse : )')
        adresse           =  extraction.call(bloc_lieu, '(Adresse : )'        ,'(Adresse militaire : )')
        adresse_militaire =  extraction.call(bloc_lieu, '(Adresse militaire : )',-1)

        Lieu ||= Struct.new(:employeur, :localisation, :etablissement ,:adresse , :adresse_militaire)
        hash_lieu = Lieu.new(employeur, localisation, etablissement, adresse , adresse_militaire).to_h
    #bloc contact
    ##--------------------------------------------------------------------------------------------------------------------------------------------------
        row_fonction = bloc_contact.slice!(extraction.call(bloc_contact, '(Fonction : )', '(Adresse mèl : )', true))   #certaines fonction sont sur 2 lignes
        hash_contact = Hash[*bloc_contact[(bloc_contact.index('(Identité : )')-1)..(bloc_contact.index(/\(Page .+\)/)-1)].scan( /\((.+?)\)/).map{|a| a[0].to_s}]
    ##------------------------------------------------------------------------------------------------------------------------------------------

        table_stage << hash_stage.merge(hash_lieu).merge(hash_contact.merge({"Fonction :"=>row_fonction}))
    rescue => monerreur
        p monerreur
        table_erreur << stage.join.match(/\(Page .+?\)/)[0]     #les page qui pose problemes
        table_erreur2 << stage.join                             #infos complet des stages non intégrés
				p table_erreur
    end
end

#transformation de toutes clés de hash en symbole
table_Stage = []
table_stage.each{|stage| table_Stage << stage.map{|a,b| (a.class==Symbol)? [a, b]:[a.sub(":","").strip.tr_s(" ","_").to_sym, b]}.to_h}


# Enregistrement des données en base
table_Stage.each do |stage|
    row_stage = Stage.new
    row_stage.Nombre_de_places        =stage[:Nombre_de_places]
    row_stage.Période                 =stage[:Période]
    row_stage.Duree                   =stage[:"Duree_(en_jours"]
    row_stage.Niveau_demandé          =stage[:Niveau_demandé]
    row_stage.Descriptif              =stage[:Descriptif]
    row_stage.Autres_commentaires     =stage[:Autres_commentaires]
    row_stage.Logement                =stage[:Logement]
    row_stage.Restauration            =stage[:Restauration]
    row_stage.précision_durée         =stage[:précision_durée]
    row_stage.employeur               =stage[:employeur]
    row_stage.localisation            =stage[:localisation]
    row_stage.etablissement           =stage[:etablissement]
    row_stage.adresse                 =stage[:adresse]
    row_stage.adresse_militaire       =stage[:adresse_militaire]
    row_stage.Identité                =stage[:Identité]
    row_stage.Adresse_mèl             =stage[:Adresse_mèl]
    row_stage.Téléphone               =stage[:Téléphone]
    row_stage.Fax                     =stage[:Fax]
    row_stage.Fonction                =stage[:Fonction]
    row_stage.save
end

# rails g model Stage Nombre_de_places Période Duree Niveau_demandé Descriptif:text Autres_commentaires:text Logement Restauration précision_durée employeur localisation etablissement adresse  adresse_militaire Identité Adresse_mèl Téléphone Fax Fonction
# rails db:migrate
