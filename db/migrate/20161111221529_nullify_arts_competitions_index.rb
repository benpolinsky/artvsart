class NullifyArtsCompetitionsIndex < ActiveRecord::Migration[5.0]
  def up
    remove_foreign_key :competitions, :arts
    add_foreign_key :competitions, :arts, on_delete: :nullify
  end
  
  def down
    remove_foreign_key :competitions, :arts
    add_foreign_key :competitions, :arts
  end
end
