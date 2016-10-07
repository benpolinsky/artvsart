class AddCategoryToArts < ActiveRecord::Migration[5.0]
  def change
    add_reference :arts, :category, foreign_key: true
  end
end
