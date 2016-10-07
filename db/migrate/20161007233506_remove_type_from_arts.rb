class RemoveTypeFromArts < ActiveRecord::Migration[5.0]
  def up
    remove_column :arts, :type
  end
  
  def down
    add_column :arts, :type, :string
  end
end
