class CreateCompetitions < ActiveRecord::Migration[5.0]
  def up
    create_table :competitions do |t|
      t.integer :challenger_id
      t.references :art, foreign_key: true
      t.integer :winner_id

      t.timestamps
    end
    
    add_index :competitions, :challenger_id
    add_index :competitions, :winner_id
  end
  
  def down
    drop_table :competitions
  end
end
