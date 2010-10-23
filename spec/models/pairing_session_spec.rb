require 'spec_helper'

describe PairingSession do
  subject {Factory.build(:pairing_session)}

  it "should have a valid factory" do
    subject.should be_valid
  end

  it "should have an owner" do
    email = "hello@world.com"
    owner = Factory.build(:user, :email => email)
    subject.owner = owner
    subject.save!
    subject.reload

    subject.owner.email.should == email

  end
end
