# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# Scrapping_Professors1


# Tutoriel des fonctionnalités:

## fichiers importants:
```
/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/app/services/scrap_fb_pros.rb
/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/app/services/scrap_urls_pros.rb
/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/config/application.yml
```
 <!-- ENV["token"]
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

# ENV["SPEADSHEET_LIENS_ET_IDS"] -->

```
/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/app/views/scrappings/home.html.erb
/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/app/views/scrappings/search.html.erb
/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/app/views/scrappings/search2.html.erb

/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/app/models/evenement.rb
/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/db/schema.rb
```

```ruby
*/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/Gemfile*
gem 'activerecord-diff'           #ajout
gem "figaro"			                   #ajout

gem "google_drive"                #ajout
gem 'watir'                       #ajout
gem 'nokogiri'           	        #ajout

gem "koala"			                    #ajout  gem facebook
```

```ruby
/home/syb8/Documents/Projet_Final/fonctionalite_scrap/Scrap_pro4/config/routes.rb
get  'scrappings/search2'
get  'scrappings/search'
root 'scrappings#home'
```


## Démarche pour récupérer les événements sur facebook:
* étape n°0 :avoir les variable d'environnement définies
* étape n°1 :récupérer/Avoir un token valide:                     ScrapFbPros.new.get_token(ou par un autre moyen possible)
* étape n°2 :créer une table de BDD suivant le modèle Evenement   rails db:create
* étape n°3 :Lancer le programme principal:                       ScrapFbPros.new.perform


## pour récupérer un token via ScrapFbPros.new.get_token:

```ruby
1 mettre ses identifiant Facebook
            ENV["FACEBOOK_EMAIL"]
            ENV["FACEBOOK_MDP"]
2 copié le nouveau token et remplacer l'ancien token de la variable environnement ENV["token"] par le nouveau token récupéré. Ce token est valide pendant 6mois.
            2 bis possibilité d'utiliser le token disponible via l'interface API graph facebook, celui-ci est valide pendant 1 heure. 
```
