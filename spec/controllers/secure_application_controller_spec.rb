require 'spec_helper'

describe SecureApplicationController do

  controller(SecureApplicationController) do
    def index
      render :text => "hello from index"
    end
  end

  it "is an application controller" do
    @controller.is_a?(ApplicationController).should be_true
  end

  describe "without being logged in" do
    it "should redirect to the login page" do
      get :index
      response.should redirect_to('/users/sign_in')
    end
  end

  describe "with being logged in" do
    before(:each) do
      sign_in Factory.create(:user)
    end
    it "should let me on through" do
      get :index
      response.body.should == "hello from index"
    end
  end

end