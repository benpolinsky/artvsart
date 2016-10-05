class UserSerializer < ActiveModel::Serializer
  attributes :email, :auth_token, :type
  
  def type
    object.admin? ? 'admin' : object.type
  end
end