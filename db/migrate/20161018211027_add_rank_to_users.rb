class AddRankToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :rank, :integer
    add_index :users, :rank
  end
end
