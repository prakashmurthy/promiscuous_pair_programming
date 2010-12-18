require 'spec_helper'

describe SecureApplicationController do

  controller(SecureApplicationController) do
    def index
      render :text => "hello from index"
    end

    def show
      raise ::Forbidden403Exception
    end
  end

  it "is an application controller" do
    @controller.is_a?(ApplicationController).should be_true
  end

  describe "without being signed in" do
    it "should redirect to the sign-in page" do
      get :index
      response.should redirect_to('/users/sign_in')
    end
  end

  describe "with being signed in" do
    before(:each) do
      sign_in Factory.create(:user)
    end
    it "should let me on through" do
      get :index
      response.body.should == "hello from index"
    end

    describe "rendering error pages" do
      it "should render public/403.html in response to a 403ForbiddenException" do
        get :show, :id => 1
        response.status.should == 403
        response.body.should =~ /You are not authorized to perform this action \(403\)/
      end
    end
  end
end