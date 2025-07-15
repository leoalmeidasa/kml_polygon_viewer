class AddFieldToPolygons < ActiveRecord::Migration[8.0]
  def change
    add_column :polygons, :field_name, :string
  end
end
