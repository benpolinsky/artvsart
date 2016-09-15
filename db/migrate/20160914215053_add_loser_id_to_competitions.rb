class AddLoserIdToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :loser_id, :integer
    add_index :competitions, :loser_id
  end
end
