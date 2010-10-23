require 'spec_helper'

describe PairingSession do
  subject { Factory.build(:pairing_session) }

  it "should have a valid factory" do
    subject.should be_valid
  end

  describe "associations" do
    it "should have an owner" do
      email         = "hello@world.com"
      owner         = Factory.build(:user, :email => email)
      subject.owner = owner
      subject.save!
      subject.reload

      subject.owner.email.should == email

    end
  end

  describe "validations" do
    it "should require a description" do
      subject.description = nil

      subject.should_not be_valid

      subject.description = ""

      subject.should_not be_valid
    end

#    it "should require a valid date" do
#      subject.meeting_date = "hello"
#      subject.should_not be_valid
#
#      subject.meeting_date = "12/40/2010"
#      subject.should_not be_valid
#    end
  end
end
