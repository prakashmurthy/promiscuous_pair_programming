require 'spec_helper'

describe PairingSessionsController do

  it "inherits from SecureApplicationController" do
    @controller.is_a?(SecureApplicationController).should be_true
  end

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

  def mock_owner(stubs={})
    (@mock_owner ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    @user = Factory.create(:user)
    sign_in @user
  end

  describe "GET index" do
    ### TODO: We should really stub these named scopes........

    describe "without a show_all parameter" do
      it "assigns my pairing_sessions as @pairing_sessions" do
        (ordered_pairing_sessions = Object.new).should_receive(:upcoming) { :upcoming_pairing_sessions }
        (pairing_sessions = Object.new).should_receive(:order).with(:start_at) { ordered_pairing_sessions }
        (current_user = mock_user).should_receive(:owned_pairing_sessions) { pairing_sessions }
        controller.stub(:current_user) { current_user }
        get :index
        assigns(:my_pairing_sessions).should == :upcoming_pairing_sessions
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
        assigns(:my_pairing_sessions).should == [future_session_two, future_session_one] # see above for why in this order
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
        assigns(:my_pairing_sessions).should == [past_session, future_session]
      end
    end
    
    it "stores params[:location] in session if it's present" do
      current_user = mock_user
      controller.stub(:current_user) { current_user }
      controller.stub_chain("current_location.coordinates") { "39.39023, -109.390293" }
      
      controller.should_receive(:current_location=).with("location")
      get :index, :location => "location"
    end
    it "doesn't store params[:location] in session if it's not present" do
      current_user = mock_user
      controller.stub(:current_user) { current_user }
      controller.stub_chain("current_location.coordinates") { "39.39023, -109.390293" }
      
      controller.should_not_receive(:current_location=)
      get :index
    end
    
    it "stores params[:radius] in session if it's present" do
      current_user = mock_user
      controller.stub(:current_user) { current_user }
      controller.stub(:current_radius) { 10 }
      
      controller.should_receive(:current_radius=).with("radius")
      get :index, :radius => "radius"
    end
    it "doesn't store params[:radius] in session if it's not present" do
      current_user = mock_user
      controller.stub(:current_user) { current_user }
      controller.stub(:current_radius) { 10 }
      
      controller.should_not_receive(:current_radius=)
      get :index
    end
    
    it "sets @available_pairing_sessions to the available pairing sessions" do
      current_user = mock_user
      controller.stub(:current_user) { current_user }
      controller.stub(:current_radius) { 10 }
      controller.stub_chain("current_location.coordinates") { "39.39023, -109.390293" }
      
      (geo_scope = Object.new).should_receive(:includes).with(:location) { :available_pairing_sessions }
      (upcoming = Object.new).should_receive(:geo_scope).with(:within => 10, :origin => "39.39023, -109.390293") { geo_scope }
      (without_pair = Object.new).should_receive(:upcoming) { upcoming }
      (not_owned_by = Object.new).should_receive(:without_pair) { without_pair }
      PairingSession.should_receive(:not_owned_by).with(current_user) { not_owned_by }
      
      get :index
      
      assigns(:available_pairing_sessions).should == :available_pairing_sessions
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
    describe "when owner matches current user" do
      before(:each) do
        @controller.stub(:current_user) { mock_owner }
        PairingSession.stub(:find).with("37") { mock_pairing_session(:owner => mock_owner) }
      end
      it "assigns the requested pairing_session as @pairing_session" do
        get :edit, :id => "37"
        assigns(:pairing_session).should be(mock_pairing_session)
      end
      it "should return a status of 200" do
        get :edit, :id => "37"
        response.status.should == 200
      end
      it "should render the edit template" do
        get :edit, :id => "37"
        response.should render_template("edit")
      end
    end

    describe "when owner does not match current user" do
      before(:each) do
        @controller.stub(:current_user) { mock_user }
        PairingSession.stub(:find).with("37") { mock_pairing_session(:owner => mock_owner) }
      end

      it "should return a status of 403 (Forbidden)" do
        get :edit, :id => "37"
        response.status.should == 403
      end
      it "should return the content from public/403.html" do
        get :edit, :id => "37"
        response.body.should =~ /You are not authorized to perform this action \(403\)/
      end
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
    describe "when owner matches current user" do
      before(:each) do
        @controller.stub(:current_user) { mock_owner }
      end
      describe "with valid params" do
        before(:each) do
          PairingSession.should_receive(:find).with("37") { mock_pairing_session(:owner => mock_owner,
                                                                                 :attributes= => nil,
                                                                                 :save => true) }
        end
        it "updates the requested pairing_session" do
          mock_pairing_session.should_receive(:attributes=).with({'these' => 'params'})
          put :update, :id => "37", :pairing_session => {'these' => 'params'}
        end

        it "assigns the requested pairing_session as @pairing_session" do
          put :update, :id => "37"
          assigns(:pairing_session).should be(mock_pairing_session)
        end

        it "will update the pair_id if specified" do
          mock_pairing_session.should_receive(:attributes=).with({'pair_id' => '8'})
          put :update, :id => "37", :pairing_session => {'pair_id' => '8'}
        end

        it "redirects to the pairing_session" do
          put :update, :id => "37"
          response.should redirect_to(pairing_sessions_path)
        end
      end

      describe "with invalid params" do
        before(:each) do
          PairingSession.stub(:find) { mock_pairing_session(:owner => mock_owner,
                                                            :attributes= => nil,
                                                            :save => false) }
        end
        it "assigns the pairing_session as @pairing_session" do
          put :update, :id => "1"
          assigns(:pairing_session).should be(mock_pairing_session)
        end

        it "re-renders the 'edit' template" do
          put :update, :id => "1"
          response.should render_template("edit")
        end
      end
    end
    describe "when current user is not the owner of the session" do
      before(:each) do
        @controller.stub(:current_user) { mock_user }
        PairingSession.stub(:find).with("37") { mock_pairing_session(:owner => mock_owner) }
      end
      it "should return a status of 403 (Forbidden)" do
        put :update, :id => "37"
        response.status.should == 403
      end
      it "should return the content from public/403.html" do
        put :update, :id => "37"
        response.body.should =~ /You are not authorized to perform this action \(403\)/
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

  describe "PUT set_pair_on" do
    describe "with successful update" do
      before(:each) do
        PairingSession.stub(:find) { mock_pairing_session(:update_attributes => true) }
        put :set_pair_on, :id => "1"
      end
      it "should set the notice" do
        flash[:notice].should_not be_empty
      end
      it "should redirect to the pairing sessions page" do
        response.should redirect_to(pairing_sessions_url)
      end
    end

    describe "with unsuccessful update" do
      before(:each) do
        PairingSession.stub(:find) { mock_pairing_session(:update_attributes => false) }
        put :set_pair_on, :id => "1"
      end
      it "should set the notice" do
        flash[:alert].should_not be_empty
      end
      it "should redirect to the pairing sessions page" do
        response.should redirect_to(pairing_sessions_url)
      end
    end
  end

  describe "PUT remove_pair_from" do
    describe "with successful update" do
      before(:each) do
        PairingSession.stub(:find) { mock_pairing_session(:update_attributes => true) }
        put :remove_pair_from, :id => "1"
      end
      it "should set the notice" do
        flash[:notice].should_not be_empty
      end
      it "should redirect to the pairing sessions page" do
        response.should redirect_to(pairing_sessions_url)
      end
    end

    describe "with unsuccessful update" do
      before(:each) do
        PairingSession.stub(:find) { mock_pairing_session(:update_attributes => false) }
        put :remove_pair_from, :id => "1"
      end
      it "should set the notice" do
        flash[:alert].should_not be_empty
      end
      it "should redirect to the pairing sessions page" do
        response.should redirect_to(pairing_sessions_url)
      end
    end
  end

end
