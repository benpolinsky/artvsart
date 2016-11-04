class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :color, :slug, :parent_category, :parent_id
  
  def parent_category
    object.parent.name if object.parent
  end
end
