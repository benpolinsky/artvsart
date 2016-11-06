class UserSerializer < ActiveModel::Serializer
  attributes :email, :auth_token, :type, :gravatar_hash, :identities, :username
  
  def type
    object.admin? ? 'admin' : object.type
  end
  
  def identities
    object.identities && object.identities.map(&:provider)
  end
end