class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :color, :slug, :parent_category, :parent_id, :root
  
  def parent_category
    object.parent.name if object.parent
  end
  
  def root
    object.root?
  end
end
