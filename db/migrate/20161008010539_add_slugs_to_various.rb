class AddSlugsToVarious < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :slug, :string, unique: true
    add_column :arts, :slug, :string, unique: true
    add_column :competitions, :slug, :string, unique: true
  end
end
