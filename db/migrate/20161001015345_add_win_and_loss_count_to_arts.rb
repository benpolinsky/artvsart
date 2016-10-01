class AddWinAndLossCountToArts < ActiveRecord::Migration[5.0]
  def change
    add_column :arts, :win_count, :integer, default: 0
    add_column :arts, :loss_count, :integer, default: 0
  end
end
