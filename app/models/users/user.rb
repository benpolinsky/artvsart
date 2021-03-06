class User < ApplicationRecord
  has_many :competitions
  has_many :identities

  devise :database_authenticatable, :registerable,
     :recoverable, :rememberable, :trackable, :validatable,
     :confirmable, :omniauthable, 
     :omniauth_providers => [:facebook, :github]
    
  acts_as_paranoid
  
  before_create :generate_auth_token!
  
  def unjudged_competitions
    competitions.unjudged
  end
  
  def judged_competitions
    competitions.judged
  end
  
  
  def generate_auth_token!
    self.auth_token =  Devise.friendly_token
  end

  def judge(competition, winner: nil)
    competition.select_winner(winner)
    update(judged_competitions_count: judged_competitions_count + 1)
    competition
  end
  
  
  def elevate_to(params={})    
    assign_attributes({
      email: params[:email], 
      password: params[:password], 
      password_confirmation: params[:password], 
      type: params[:type], 
      confirmed_at: nil
    })
    if valid?
      save
      send_confirmation_instructions if params[:type] == 'UnconfirmedUser'
      self
    else
      self
    end
  end
  
  def gravatar_hash
    md5 = Digest::MD5.new
    md5.update formatted_email
    md5.hexdigest
  end
  
  # Refactor into AuthService.
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

  def self.ranked_judges
    judges.where("rank > 0 AND rank IS NOT NULL").order(rank: :asc)
  end
  
  def self.judges
    where("judged_competitions_count > 0 AND judged_competitions_count IS NOT NULL")
  end
  
  def self.top_judges
    judges.where(type: nil).or(admins).order(judged_competitions_count: :desc)
  end
  
  def self.admins
    where(admin: true)
  end
  
  
  # https://github.com/telent/ar-as-batches eventually
  def self.rank!(reset=false)
    update_all(rank: nil) if reset
    top_judges.each_with_index do |judge, index| 
      judge.update(rank: index+1)
    end
  end
  
  

  
  private
  
  def formatted_email
    self.email.strip.downcase
  end
end
