class ArtSerializer < ActiveModel::Serializer
  attributes :id, :name, :creator, :description, :status, :image
end
