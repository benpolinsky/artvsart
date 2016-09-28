require 'rails_helper'

RSpec.describe User, type: :model do
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
end