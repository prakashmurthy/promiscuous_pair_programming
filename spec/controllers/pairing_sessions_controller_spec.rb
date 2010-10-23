require 'spec_helper'

describe PairingSessionsController do

  def mock_pairing_session(stubs={})
    (@mock_pairing_session ||= mock_model(PairingSession).as_null_object).tap do |pairing_session|
      pairing_session.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all pairing_sessions as @pairing_sessions" do
      PairingSession.stub(:all) { [mock_pairing_session] }
      get :index
      assigns(:pairing_sessions).should eq([mock_pairing_session])
    end
  end

  describe "GET show" do
    it "assigns the requested pairing_session as @pairing_session" do
      PairingSession.stub(:find).with("37") { mock_pairing_session }
      get :show, :id => "37"
      assigns(:pairing_session).should be(mock_pairing_session)
    end
  end

  describe "GET new" do
    it "assigns a new pairing_session as @pairing_session" do
      PairingSession.stub(:new) { mock_pairing_session }
      get :new
      assigns(:pairing_session).should be(mock_pairing_session)
    end
  end

  describe "GET edit" do
    it "assigns the requested pairing_session as @pairing_session" do
      PairingSession.stub(:find).with("37") { mock_pairing_session }
      get :edit, :id => "37"
      assigns(:pairing_session).should be(mock_pairing_session)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created pairing_session as @pairing_session" do
        PairingSession.stub(:new).with({'these' => 'params'}) { mock_pairing_session(:save => true) }
        post :create, :pairing_session => {'these' => 'params'}
        assigns(:pairing_session).should be(mock_pairing_session)
      end

      it "redirects to the created pairing_session" do
        PairingSession.stub(:new) { mock_pairing_session(:save => true) }
        post :create, :pairing_session => {}
        response.should redirect_to(pairing_sessions_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved pairing_session as @pairing_session" do
        PairingSession.stub(:new).with({'these' => 'params'}) { mock_pairing_session(:save => false) }
        post :create, :pairing_session => {'these' => 'params'}
        assigns(:pairing_session).should be(mock_pairing_session)
      end

      it "re-renders the 'new' template" do
        PairingSession.stub(:new) { mock_pairing_session(:save => false) }
        post :create, :pairing_session => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested pairing_session" do
        PairingSession.should_receive(:find).with("37") { mock_pairing_session }
        mock_pairing_session.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :pairing_session => {'these' => 'params'}
      end

      it "assigns the requested pairing_session as @pairing_session" do
        PairingSession.stub(:find) { mock_pairing_session(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:pairing_session).should be(mock_pairing_session)
      end

      it "redirects to the pairing_session" do
        PairingSession.stub(:find) { mock_pairing_session(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(pairing_session_url(mock_pairing_session))
      end
    end

    describe "with invalid params" do
      it "assigns the pairing_session as @pairing_session" do
        PairingSession.stub(:find) { mock_pairing_session(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:pairing_session).should be(mock_pairing_session)
      end

      it "re-renders the 'edit' template" do
        PairingSession.stub(:find) { mock_pairing_session(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested pairing_session" do
      PairingSession.should_receive(:find).with("37") { mock_pairing_session }
      mock_pairing_session.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the pairing_sessions list" do
      PairingSession.stub(:find) { mock_pairing_session }
      delete :destroy, :id => "1"
      response.should redirect_to(pairing_sessions_url)
    end
  end

end
