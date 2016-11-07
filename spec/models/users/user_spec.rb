require 'rails_helper'

RSpec.describe User, type: :model do
  
  before do
    Competition.delete_all
  end
  
  let(:user){User.new}
  
  context "attributes" do
    it "has an email" do
      expect(user.email).to_not be_nil
    end
    
    it "has a encrypted_password" do
      expect(user.encrypted_password).to_not be_nil
    end
    
    it "has an auth token" do
      expect(user.auth_token).to_not be_nil
    end
  end
  
  context "validations" do
    it "email is required" do
      expect{user.valid?}.to change{user.errors[:email].size}.from(0).to(1)
    end
    
    it "email must be unique" do
      new_user = User.new(email: user.email, password: "OKAY")
      expect{new_user.valid?}.to change{new_user.errors[:email].size}.from(0).to(1)
    end

    it "password is required" do
      expect{user.valid?}.to change{user.errors[:password].size}.from(0).to(1)
    end

  end
  
  context '#generate_auth_token!' do
    it "generates a token" do
      allow(Devise).to receive(:friendly_token).and_return("myspecialtoken")
      user.generate_auth_token!
      expect(user.auth_token).to eq "myspecialtoken"
    end
    
    it "generates a token on create" do
      new_user = User.create(email: "okay@okay.com", password: "passwordpaass")
      expect(new_user.auth_token).to_not be_blank
    end
  end
  
  context "roles" do
    it 'can be an admin' do
      new_user = User.create(email: "okay@okay.com", password: "passwordpaass")
      expect(new_user.admin?).to eq false
      
      new_user.update(admin: true)
      expect(new_user.admin?).to eq true      
    end
  end
  
  context '#judged_competitions' do
    it "has many judged_competitions" do   
      competitions = create_list(:judged_competitions, 2)
      user = create(:user)
      user.judged_competitions << competitions
      expect(user.judged_competitions.count).to eq 2
    end
    
    it "can #judge a competition" do
      unjudged_competitions = create_list(:competition, 2)
      user = create(:user)
      unjudged_competitions.each do |competition|
        user.judge(competition, winner: competition.art_id)
      end
      expect(user.judged_competitions.size).to eq 2
    end 
  end
  
  context "identities" do
    it "creates an identity with uid and provider" do
      mock_auth = Hashie::Mash.new({provider: 'facebook', uid: "3i47u29834", info: {email: 'ben@ben.com'}})
      new_user = User.from_omniauth(mock_auth)
      expect(new_user.email).to eq 'ben@ben.com'
      expect(new_user.identities.count).to eq 1
      expect(new_user.identities.first.uid).to eq "3i47u29834"
    end
  end
  
  context "gravatars" do
    it "computes a md5 hash from its email" do
      user.email = "ben@ben.com"
      expect(user.gravatar_hash).to eq 'a8eeb68641395ea82ac1c8783306548e'
    end
    
    it "removes whitespace in emails" do
      user.email = " ben@ben.com "
      expect(user.gravatar_hash).to eq 'a8eeb68641395ea82ac1c8783306548e'
    end
    
    it "downcases all characters" do
      user.email = "BeN@BEN.COm"
      expect(user.gravatar_hash).to eq 'a8eeb68641395ea82ac1c8783306548e'
    end
  end
  
  context "deletion" do
    it "only soft deletes a user" do
      ben = create(:user)
      ben.destroy
      expect(ben.deleted?).to eq true
      expect(User.find_by(id: ben.id)).to eq nil
      expect(User.with_deleted.find(ben.id)).to eq ben
    end
  end 

  

end