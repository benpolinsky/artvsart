class RemoveUniqueIndexOnAuthTokens < ActiveRecord::Migration[5.0]
  def change
    remove_index :users, :auth_token
    add_index :users, :auth_token
  end
end
