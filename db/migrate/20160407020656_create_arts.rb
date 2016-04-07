class CreateArts < ActiveRecord::Migration[5.0]
  def change
    create_table :arts do |t|
      t.string :name
      t.string :creator
      t.datetime :creation_date

      t.timestamps
    end
  end
end
