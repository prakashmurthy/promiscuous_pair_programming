require 'spec_helper'

describe WelcomeController do

  describe "GET 'index'" do

    it "assigns to @pairing_sessions" do
      pairing_sessions = [Factory.stub(:pairing_session)]
      PairingSession.stub(:available).and_return(pairing_sessions)

      get :index

      assigns(:pairing_sessions).should == pairing_sessions
    end

    it "renders" do
      get :index

      response.should be_successful
      response.should render_template(:index)
    end

  end

end
