class PairingSessionsController < SecureApplicationController

  before_filter :assign_pairing_session, :except => [:index, :new, :create]

  def index
    if params[:show_all]
      @my_pairing_sessions = current_user.owned_pairing_sessions.order(:start_at)
    else
      @my_pairing_sessions = current_user.owned_pairing_sessions.upcoming.order(:start_at)
    end
    @available_pairing_sessions  = PairingSession.not_owned_by(current_user).without_pair.upcoming
    @sessions_user_is_pairing_on = current_user.pairing_sessions_as_pair
  end

  def show

  end

  def new
    @pairing_session = PairingSession.new
  end

  def edit
    if current_user == @pairing_session.owner
      render :edit
    else
      render :status => 403, :file => Rails.root.join("public", "403.html"), :layout => false
    end
  end

  # TODO: use scoped builder instead of assigning to owner
  def create
    @pairing_session       = PairingSession.new(params[:pairing_session])
    @pairing_session.owner = current_user

    if @pairing_session.save
      redirect_to(pairing_sessions_path, :notice => 'Pairing session was successfully created.') and return
    end
    render :new
  end

  def update
    if current_user == @pairing_session.owner
      if @pairing_session.update_attributes(params[:pairing_session])
        redirect_to(pairing_sessions_path, :notice => 'Pairing session was successfully updated.')
      else
        render :edit
      end
    else
      render :status => 403, :file => Rails.root.join("public", "403.html"), :layout => false
    end
  end

  def destroy
    @pairing_session.destroy
    redirect_to(pairing_sessions_url, :notice => 'Pairing session was successfully deleted.')
  end

  def set_pair_on
    if @pairing_session.update_attributes(:pair => current_user)
      redirect_to(pairing_sessions_path, :notice => 'You are the lucky winner. Have a good time.')
    else
      redirect_to(pairing_sessions_path, :alert => "Sorry but I couldn't set you are the pair for this session.")
    end
  end

  def remove_pair_from
    if @pairing_session.update_attributes(:pair => nil)
      redirect_to(pairing_sessions_path, :notice => 'Sorry to see you go. Maybe next time.')
    else
      redirect_to(pairing_sessions_path, :alert => "Sorry but I couldn't remove you as the pair for this session.")
    end
  end

  private

  def assign_pairing_session
    @pairing_session = PairingSession.find(params[:id])
  end
end
