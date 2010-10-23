require "spec_helper"

describe PairingSessionsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/pairing_sessions" }.should route_to(:controller => "pairing_sessions", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/pairing_sessions/new" }.should route_to(:controller => "pairing_sessions", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/pairing_sessions/1" }.should route_to(:controller => "pairing_sessions", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/pairing_sessions/1/edit" }.should route_to(:controller => "pairing_sessions", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/pairing_sessions" }.should route_to(:controller => "pairing_sessions", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/pairing_sessions/1" }.should route_to(:controller => "pairing_sessions", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/pairing_sessions/1" }.should route_to(:controller => "pairing_sessions", :action => "destroy", :id => "1")
    end

  end
end
