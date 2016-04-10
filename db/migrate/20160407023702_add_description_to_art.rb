class AddDescriptionToArt < ActiveRecord::Migration[5.0]
  def change
    add_column :arts, :description, :text
  end
end
