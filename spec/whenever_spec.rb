require 'rails_helper'

RSpec.describe "Schedule.rb" do
  before do
    load 'Rakefile'
    @schedule = Whenever::Test::Schedule.new(file: 'config/schedule.rb')
  end
  
  it 'has the rank_users task' do
    expect(@schedule.jobs[:rake].map{|job| job[:task]}).to include 'rank_users'
  end
  
  it "runs rank_users every hour" do
    expect(@schedule.jobs[:rake].find{|a| a[:task] == "rank_users"}[:every].first).to eq(1.hour)
  end
end
