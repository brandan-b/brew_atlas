class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :code
      t.string :region
      t.string :capital
      t.integer :population
      t.float :area
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
