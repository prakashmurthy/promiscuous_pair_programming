class PairingSessionsController < ApplicationController
  # GET /pairing_sessions
  def index
    @pairing_sessions = current_user.pairing_sessions

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /pairing_sessions/1
  def show
    @pairing_session = PairingSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /pairing_sessions/new
  def new
    @pairing_session = PairingSession.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /pairing_sessions/1/edit
  def edit
    @pairing_session = PairingSession.find(params[:id])
  end

  # POST /pairing_sessions
  def create
    @pairing_session = PairingSession.new(params[:pairing_session])
    @pairing_session.owner = current_user

    respond_to do |format|
      if @pairing_session.save
        format.html { redirect_to(pairing_sessions_path, :notice => 'Pairing session was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /pairing_sessions/1
  def update
    @pairing_session = PairingSession.find(params[:id])

    respond_to do |format|
      if @pairing_session.update_attributes(params[:pairing_session])
        format.html { redirect_to(@pairing_session, :notice => 'Pairing session was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /pairing_sessions/1
  def destroy
    @pairing_session = PairingSession.find(params[:id])
    @pairing_session.destroy

    respond_to do |format|
      format.html { redirect_to(pairing_sessions_url, :notice => 'Pairing session was successfully deleted.') }
    end
  end
end
