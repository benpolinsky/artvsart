class AddImageToArt < ActiveRecord::Migration[5.0]
  def change
    add_column :arts, :image, :string
  end
end
