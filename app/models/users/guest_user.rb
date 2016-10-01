class GuestUser < User
  after_initialize :fill_guest_fields
  
  def judge(competition, winner: nil)
    if judged_competitions.size < 10
      super(competition, winner: winner)
    else
      competition.errors.add(:base, 'Guest Users can only Judge 10 times.  Please Sign Up!')
      competition
    end
  end
  
  def elevate_to_user(params={})
    update(email: params[:email], password: params[:password], password_confirmation: params[:password], type: nil)
    self
  end
  
  private
  
  def fill_guest_fields
    assign_attributes({
      email: "guest_user_#{Time.zone.now.to_i+rand(10000)}@guest.com",
      password: "password"
      }) if email.blank?
  end
  
end