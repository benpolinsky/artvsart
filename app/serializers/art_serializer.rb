class ArtSerializer < ActiveModel::Serializer
  attributes :id, :name, :creator, :description, :status, :image, 
  :win_loss_record, :win_loss_percentage, :win_loss_rate, :win_count,
  :loss_count
  
  def image
    object.image || 'http://placehold.it/250x250'
  end
  
  def win_loss_rate
    object.win_loss_rate.to_s || ""
  end
end
