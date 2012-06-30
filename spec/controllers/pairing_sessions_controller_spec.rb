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
    @current_user = mock_user
    controller.stub(:current_user) { @current_user }
    controller.stub(:authenticate_user!) { true }
  end
 
  describe "GET index" do
    # Have to stub these before each test even if the test doesn't concern them
    # because the controller attempts to set them every time we hit the index action
     
    def stub_current_radius_and_location
      @current_radius = 10
      @current_location = Object.new
      controller.stub(:current_radius) { @current_radius }
      controller.stub(:current_location) { @current_location }
    end
     
    def stub_finders(stub_options={})
      methods = [
        :my_involved_pairing_sessions,
        :my_open_pairing_sessions,
        :available_pairing_sessions 
      ]
      methods.each {|m| send("stub_#{m}", stub_options[m]) unless stub_options[m] == false }
    end
     
    def stub_my_involved_pairing_sessions(stub_or_mock=:stub)
      stub_or_mock_method = (stub_or_mock == :stub) ? :stub : :should_receive
      (upcoming_collection = Object.new).send(stub_or_mock_method, :upcoming) { :my_involved_pairing_sessions }
      (ordered_collection = Object.new).send(stub_or_mock_method, :order) { upcoming_collection }
      PairingSession.send(stub_or_mock_method, :involving).with(@current_user) { ordered_collection }
    end
     
    def stub_my_open_pairing_sessions(stub_or_mock=:stub)
      stub_or_mock_method = (stub_or_mock == :stub) ? :stub : :should_receive
      (ordered_collection = Object.new).send(stub_or_mock_method, :order) { :my_open_pairing_sessions }
      (collection = Object.new).send(stub_or_mock_method, :without_pair) { ordered_collection }
      @current_user.send(stub_or_mock_method, :owned_pairing_sessions) { collection }
    end
     
    def stub_available_pairing_sessions(stub_or_mock=:stub)
      stub_or_mock_method = (stub_or_mock == :stub) ? :stub : :should_receive
      (ordered_collection = Object.new).send(stub_or_mock_method, :order) { :available_pairing_sessions }
      (collection = Object.new).send(stub_or_mock_method, :location_scoped).with(:distance => @current_radius, :around => @current_location) { ordered_collection }
      PairingSession.send(stub_or_mock_method, :available_to).with(@current_user) { collection }
    end
     
    def stub_methods(stub_options={})
      stub_current_radius_and_location
      stub_finders(stub_options)
    end
     
    it "stores params[:location] in session if it's present" do
      controller.should_receive(:current_location=).with("location")
      stub_methods
      get :index, :location => "location"
    end
    it "doesn't store params[:location] in session if it's not present" do
      controller.should_not_receive(:current_location=)
      stub_methods
      get :index
    end
     
    it "stores params[:radius] in session if it's present" do
      controller.should_receive(:current_radius=).with("radius")
      stub_methods
      get :index, :radius => "radius"
    end
    it "doesn't store params[:radius] in session if it's not present" do
      controller.should_not_receive(:current_radius=)
      stub_methods
      get :index
    end
     
    it "sets @my_involved_pairing_sessions to the sessions where the user is owner or pair" do
      stub_methods(:my_involved_pairing_sessions => :mock)
      get :index
      assigns(:my_involved_pairing_sessions).should == :my_involved_pairing_sessions
    end
    it "drops the .upcoming scope from @my_involved_pairing_sessions if the show_all parameter was given" do
      stub_methods(:my_involved_pairing_sessions => false)
      
      (ordered_collection = Object.new).should_receive(:order) { :my_involved_pairing_sessions }
      PairingSession.should_receive(:involving).with(@current_user) { ordered_collection }
      
      get :index, :show_all => 1
      assigns(:my_involved_pairing_sessions).should == :my_involved_pairing_sessions
    end
     
    it "sets @my_open_pairing_sessions to the user's owned pairing sessions that are without a pair" do
      stub_methods(:my_open_pairing_sessions => :mock)
      get :index
      assigns(:my_open_pairing_sessions).should == :my_open_pairing_sessions
    end
     
    it "sets @available_pairing_sessions to the available pairing sessions" do
      stub_methods(:available_pairing_sessions => :mock)
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
      @current_user.stub(:owned_pairing_sessions) {
        Object.new.tap do |x|
          x.stub(:build) { mock_pairing_session }
        end
      }
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
 
    def stub_pairing_session(stub_or_mock, options={})
      stub_or_mock_method = (stub_or_mock == :stub) ? :stub : :should_receive
      @current_user.send(stub_or_mock_method, :owned_pairing_sessions) {
        Object.new.tap {|x|
          x.send(stub_or_mock_method, :build) { mock_pairing_session(:save => options[:save]) }.tap do |y|
            y.with(options[:params]) if options[:params]
          end
        }
      }
    end
 
    describe "with valid params" do
      it "assigns a newly created pairing_session as @pairing_session" do
        stub_pairing_session(:mock, :params => {'these' => 'params'}, :save => true)
        post :create, :pairing_session => {'these' => 'params'}
        assigns(:pairing_session).should be(mock_pairing_session)
      end
 
      it "redirects to the created pairing_session" do
        stub_pairing_session(:stub, :save => true)
        post :create, :pairing_session => {}
        response.should redirect_to(pairing_sessions_path)
      end
    end
 
    describe "with invalid params" do
      it "assigns a newly created but unsaved pairing_session as @pairing_session" do
        stub_pairing_session(:mock, :params => {'these' => 'params'}, :save => false)
        post :create, :pairing_session => {'these' => 'params'}
        assigns(:pairing_session).should be(mock_pairing_session)
      end
 
      it "re-renders the 'new' template" do
        stub_pairing_session(:stub, :save => false)
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