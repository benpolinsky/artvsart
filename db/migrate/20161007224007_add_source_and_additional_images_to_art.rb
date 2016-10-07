class AddSourceAndAdditionalImagesToArt < ActiveRecord::Migration[5.0]
  def change
    add_column :arts, :additional_images, :text
    add_column :arts, :source, :string
    add_column :arts, :type, :string
    add_index :arts, :type
  end
end
