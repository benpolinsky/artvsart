class UserSerializer < ActiveModel::Serializer
  attributes :email, :auth_token, :type, :gravatar_hash
  
  def type
    object.admin? ? 'admin' : object.type
  end
end