class GuestUserSerializer < ActiveModel::Serializer
  attributes :auth_token, :type, :email
end