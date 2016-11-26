class ChangeArtCreationDateToString < ActiveRecord::Migration[5.0]
  def up
    change_column :arts, :creation_date, :string
  end
  
  def down
    change_column :arts, :creation_date, :datetime
  end
end
