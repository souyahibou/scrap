class CreateStages < ActiveRecord::Migration[5.1]
  def change
    create_table :stages do |t|
      t.string :Nombre_de_places
      t.string :Période
      t.text :Duree
      t.string :Niveau_demandé
      t.text :Descriptif
      t.text :Autres_commentaires
      t.string :Logement
      t.string :Restauration
      t.string :précision_durée
      t.string :employeur
      t.string :localisation
      t.string :etablissement
      t.string :adresse
      t.string :adresse_militaire
      t.string :Identité
      t.string :Adresse_mèl
      t.string :Téléphone
      t.string :Fax
      t.string :Fonction

      t.timestamps
    end
  end
end
