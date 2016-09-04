class AddStatusToArt < ActiveRecord::Migration[5.0]
  def change
    add_column :arts, :status, :integer, default: 0
  end
end
