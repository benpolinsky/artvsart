class User < ApplicationRecord
  has_many :judged_competitions, class_name: "Competition"

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
     :recoverable, :rememberable, :trackable, :validatable

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
  
  def self.top_judges
    where(type: nil).or(where(admin: true)).order(judged_competitions_count: :desc)
  end
  
  def self.admins
    where(admin: true)
  end
end
