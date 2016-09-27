class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable
  before_create :generate_auth_token!

   def generate_auth_token!
     begin
       self.auth_token = Devise.friendly_token
     end while user_with_token_exists
   end
   
   
   protected
   def user_with_token_exists
      self.class.exists?(auth_token: auth_token)
   end
end
