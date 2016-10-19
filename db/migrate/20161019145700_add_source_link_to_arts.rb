class AddSourceLinkToArts < ActiveRecord::Migration[5.0]
  def change
    add_column :arts, :source_link, :string
  end
end
