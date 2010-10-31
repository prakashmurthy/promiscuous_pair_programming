class PairingSessionsController < ApplicationController

  before_filter :assign_pairing_session, :only => [:show, :edit, :update, :destroy]

  def index
    @pairing_sessions = current_user.pairing_sessions.upcoming
  end

  def show; end

  def new
    @pairing_session = PairingSession.new
  end

  def edit; end

  # TODO: use scoped builder instead of assigning to owner
  def create
    @pairing_session = PairingSession.new(params[:pairing_session])
    @pairing_session.owner = current_user

    if @pairing_session.save
      redirect_to(pairing_sessions_path, :notice => 'Pairing session was successfully created.') and return
    end
    render :new
  end

  def update
    if @pairing_session.update_attributes(params[:pairing_session])
      redirect_to(@pairing_session, :notice => 'Pairing session was successfully updated.') and return
    end
    render :edit
  end

  def destroy
    @pairing_session.destroy
    redirect_to(pairing_sessions_url, :notice => 'Pairing session was successfully deleted.')
  end

  private

  def assign_pairing_session
    @pairing_session = PairingSession.find(params[:id])
  end

end
