require 'rails_helper'

RSpec.describe "ranking tasks" do
  describe "rank_users" do
    it "calls User::Rank!" do
      expect(User).to receive(:rank!)
      subject.execute
    end
  end
  
  describe "calculate_elo_rankings" do
    it "calls Competition::calculate_elo_rankings!" do
      expect(Competition).to receive(:calculate_elo_rankings!)
      subject.execute
    end
  end
end