class CreateCompetitions < ActiveRecord::Migration[5.0]
  def change
    create_table :competitions do |t|
      t.integer :challenger_id
      t.references :art, foreign_key: true
      t.integer :winner

      t.timestamps
    end
  end
end
