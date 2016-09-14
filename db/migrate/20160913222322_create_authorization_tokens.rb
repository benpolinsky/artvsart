class CreateAuthorizationTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :authorization_tokens do |t|
      t.string :service
      t.text :token
      t.datetime :expires_on

      t.timestamps
    end
  end
end
