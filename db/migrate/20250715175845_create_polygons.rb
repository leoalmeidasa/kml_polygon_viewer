class CreatePolygons < ActiveRecord::Migration[8.0]
  def change
    create_table :polygons do |t|
      t.string :name
      t.text :description
      t.text :coordinates

      t.timestamps
    end
  end
end
