class CreateBreweryTags < ActiveRecord::Migration[8.0]
  def change
    create_table :brewery_tags do |t|
      t.references :brewery, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
