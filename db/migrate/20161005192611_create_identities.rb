class CreateIdentities < ActiveRecord::Migration[5.0]
  def change
    create_table :identities do |t|
      t.references :user, foreign_key: true
      t.string :provider
      t.string :uid
      t.text :token
      t.text :secret
      t.datetime :expires_at

      t.timestamps
    end
  end
end
