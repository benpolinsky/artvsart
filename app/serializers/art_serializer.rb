class ArtSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :creator, :description, :source, :status, 
  :category_name, :image, :additional_images, :creation_date,
  :win_loss_record, :win_loss_percentage, :win_loss_rate, :win_count,
  :loss_count, :category
  
  def image
    object.image || 'http://placehold.it/250x250'
  end
  
  def win_loss_rate
    object.win_loss_rate.to_s || ""
  end
  
  def category_name
    object.category.try(:name)
  end
  
  def category
    object.category ? object.category : NullCategory.new
  end
  
  def creation_date
    object.creation_date.present? ? object.creation_date.strftime('%c') : Time.zone.now.strftime('%c')
  end
end
