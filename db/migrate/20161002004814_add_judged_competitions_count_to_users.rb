class AddJudgedCompetitionsCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :judged_competitions_count, :integer, default: 0
  end
end
