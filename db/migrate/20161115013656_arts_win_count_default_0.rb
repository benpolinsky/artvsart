class ArtsWinCountDefault0 < ActiveRecord::Migration[5.0]
  def up
    change_column_default :arts, :win_count, 0
    change_column_default :arts, :loss_count, 0
  end
end
