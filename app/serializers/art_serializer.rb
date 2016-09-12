class ArtSerializer < ActiveModel::Serializer
  attributes :id, :name, :creator, :description, :status, :image
  
  def image
    object.image || 'http://placehold.it/250x250'
  end
end
