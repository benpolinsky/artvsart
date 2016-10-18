class User < ApplicationRecord
  has_many :judged_competitions, class_name: "Competition"
  has_many :identities
  
  devise :database_authenticatable, :registerable,
     :recoverable, :rememberable, :trackable, :validatable,
      :omniauthable, :omniauth_providers => [:facebook]

  before_create :generate_auth_token!

  # Love to move this into an Authentication service 
  def generate_auth_token!
    self.auth_token =  Devise.friendly_token
  end

  def judge(competition, winner: nil)
    competition.select_winner(winner, self)
    judged_competitions << competition
    competition
  end
  
  def gravatar_hash
    md5 = Digest::MD5.new
    md5.update formatted_email
    md5.hexdigest
  end
  
  def self.from_omniauth(auth)
    includes(:identities).where(identities: {provider: auth.provider, uid: auth.uid}).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.identities.build({
        provider: auth.provider,
        uid: auth.uid
      })
    end
  end

  
  def self.top_judges
    where(type: nil).or(where(admin: true)).order(judged_competitions_count: :desc)
  end
  
  def self.admins
    where(admin: true)
  end
  
  private
  
  def formatted_email
    self.email.strip.downcase
  end


end
