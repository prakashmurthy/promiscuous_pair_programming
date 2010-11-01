require 'spec_helper'

describe PairingSessionsController do

  def mock_pairing_session(stubs={})
    (@mock_pairing_session ||= mock_model(PairingSession).as_null_object).tap do |pairing_session|
      pairing_session.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    @controller.stub(:current_user) { mock_user() }
  end

  describe "GET index" do
    describe "without a show_all parameter" do
      it "assigns my pairing_sessions as @pairing_sessions" do
        expected = mock_pairing_session
        @controller.stub(:current_user) { mock_user(:pairing_sessions => stub(:upcoming => expected)) }
        get :index
        assigns(:pairing_sessions).should eq(expected)
      end

      it "sorts pairing_sessions from those starting the soonest to those starting the latest" do
        # need a user with at least two sessions to ensure order
        user               = Factory.create(:user)
        # creating the sessions out of order to make sure that sort is actually working
        future_session_one = Factory.create(:pairing_session, {:owner => user, :start_at => 2.days.from_now, :end_at => 3.days.from_now})
        future_session_two = Factory.create(:pairing_session, {:owner => user}) # default one from factory is in the future starting one day from now

        # okay, now we just need to make sure we have the user as the current one
        @controller.stub(:current_user) { user }
        # now we should get both sessions back if we view all sessions
        get :index
        assigns(:pairing_sessions).should == [future_session_two, future_session_one] # see above for why in this order
      end
    end
    describe "with a show_all parameter" do
      it "shows all pairing sessions for the user, including those in the past, and they are sorted from oldest to newest" do
        # need a user with at least two sessions, one in the future and one in the past
        user           = Factory.create(:user)
        future_session = Factory.create(:pairing_session, {:owner => user}) # default one from factory is in the future
        # need to use save(false) to bypass validation, so we'll make that one with build and then call save ourselves
        past_session   = Factory.build(:pairing_session, {:start_at    => 2.days.ago, :end_at => 1.day.ago,
                                                          :description => "Session in the past", :owner => user})
        past_session.save(:validate => false) # otherwise we can't create one in the past

        # okay, now we just need to make sure we have the user as the current one
        @controller.stub(:current_user) { user }
        # now we should get both sessions back if we view all sessions
        get :index, :show_all => true
        assigns(:pairing_sessions).should == [past_session, future_session]
      end
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
        response.should redirect_to(pairing_sessions_path)
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
