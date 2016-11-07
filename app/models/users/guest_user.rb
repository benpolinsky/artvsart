class GuestUser < User
  after_initialize :fill_guest_fields
  
  def judge(competition, winner: nil)
    if judged_competitions.size < 10
      super(competition, winner: winner)
    else
      competition.errors.add(:base, 'Please Sign Up to Continue Judging')
      competition
    end
  end

  # TODO: pull up method, rename method to transition_to 
  #  that way it'll make sense and be useful for all types, hopefully
  def elevate_to(params={})
    assign_attributes(email: params[:email], password: params[:password], password_confirmation: params[:password], type: params[:user_type], confirmed_at: nil)
    if valid?
      save
      send_confirmation_instructions if params[:type] == 'UnconfirmedUser'
      self
    else
      self
    end
  end
  
  private
  
  def fill_guest_fields
    assign_attributes({
      email: "guest_user_#{Time.zone.now.to_i+rand(10000)}@guest.com",
      password: "password"
      }) if email.blank?
  end
  
end