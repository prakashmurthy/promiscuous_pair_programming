require File.expand_path('../../spec_helper', __FILE__)

describe User do
  subject { Factory.build(:user) }
  
  it "should have a valid factory" do
    subject.should be_valid
  end
  
  context "validations" do
    it_behaves_like "a location-based model: validations"
  end

  context "associations" do
    it "should have many owned pairing sessions" do
      user            = Factory.create(:user)
      pairing_session = Factory.create(:pairing_session, :owner => user)

      user.owned_pairing_sessions.should == [pairing_session]
    end

    it "knows about the sessions that it is the pair for" do
      user            = Factory.create(:user)
      pairing_session = Factory.create(:pairing_session, :pair => user)

      user.pairing_sessions_as_pair.should == [pairing_session]
    end
  end
  
  context "on create" do
    it_behaves_like "a location-based model: create callbacks"
  end
  
  context "on update" do
    subject { Factory.create(:user) }
    it_behaves_like "a location-based model: update callbacks"
  end
  
  it_behaves_like "a location-based model"

  it "returns a full name based on first and last name" do
    user = Factory.build(:user, :first_name => 'Richard', :last_name => "Nixon")
    user.full_name.should == "Richard Nixon"
  end
  
  it "should require a first name to be valid" do
    user = Factory.build(:user, :first_name => nil)
    user.should_not be_valid
  end

  it "should require a last name to be valid" do
    user = Factory.build(:user, :last_name => nil)
    user.should_not be_valid
  end
end
# == Schema Information
#
# Table name: users
#
#  id                   :integer         not null, primary key
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  reset_password_token :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  first_name           :string(255)
#  last_name            :string(255)
#  location_id          :integer
#

