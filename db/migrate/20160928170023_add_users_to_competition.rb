class AddUsersToCompetition < ActiveRecord::Migration[5.0]
  def change
    add_reference :competitions, :user, foreign_key: true
  end
end
