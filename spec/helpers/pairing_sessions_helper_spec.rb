require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the PairingSessionsHelper. For example:
#
# describe PairingSessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe PairingSessionsHelper do

  describe "#pair_information_for" do
    it "should return a string with the full name and email if a pair is present" do
      user = Factory.build(:user, :first_name => "Hello", :last_name => "World", :email => "hello@world.com")
      helper.pair_information_for(user).should == "Hello World (hello@world.com)"
    end

    it "should return None if no pair is present" do
      helper.pair_information_for(nil).should == "None"
    end
  end
end
