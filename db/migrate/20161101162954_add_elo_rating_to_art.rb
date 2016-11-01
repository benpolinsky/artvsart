class AddEloRatingToArt < ActiveRecord::Migration[5.0]
  def change
    add_column :arts, :elo_rating, :integer
    add_index :arts, :elo_rating
  end
end
