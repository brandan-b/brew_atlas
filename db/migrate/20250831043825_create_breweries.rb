class CreateBreweries < ActiveRecord::Migration[8.0]
  def change
    create_table :breweries do |t|
      t.string :name
      t.string :brewery_type
      t.string :street
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :website_url
      t.string :phone
      t.float :latitude
      t.float :longitude
      t.string :external_id
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
