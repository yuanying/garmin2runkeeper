require 'spec_helper'

describe "User Model" do
  let(:user) { User.new }
  it 'can be created' do
    user.should_not be_nil
  end

  context "have garmin username and password" do
    let(:user) { User.new.tap { |user| user.garmin_id = 'yuanying'; user.garmin_password = 'kojiro' } }

    it 'should return recent activities' do
      user.recent_activities.should_not be_nil
    end
  end

end
