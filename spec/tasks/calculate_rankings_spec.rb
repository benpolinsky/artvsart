require 'rails_helper'

RSpec.describe "rank_users" do
  it "calls User::Rank!" do
    expect(User).to receive(:rank!)
    subject.execute
  end
end