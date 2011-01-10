class PairingSessionsController < SecureApplicationController

  before_filter :build_pairing_session, :only => [:new, :create]
  before_filter :find_pairing_session, :except => [:index, :new, :create]

  def index
    self.current_location = params[:location] if params[:location]
    self.current_radius   = params[:radius]   if params[:radius]
    
    @my_involved_pairing_sessions = begin
      scope = PairingSession.involving(current_user).order(:start_at.desc)
      params[:show_all] ? scope : scope.upcoming
    end
    @my_open_pairing_sessions = current_user.owned_pairing_sessions.without_pair.order(:start_at.desc)
    @available_pairing_sessions =
      PairingSession.available_to(current_user).
      location_scoped(:distance => current_radius, :around => current_location).
      order(:start_at.desc)
  end

  def show

  end

  def new
  end

  def create
    @pairing_session.enable_geocoding = true
    if @pairing_session.save
      redirect_to(pairing_sessions_path, :notice => 'Pairing session was successfully created.')
    else
      render :new
    end
  end
  
  def edit
    if current_user == @pairing_session.owner
      render :edit
    else
      raise ::Forbidden403Exception
    end
  end

  def update
    if current_user == @pairing_session.owner
      @pairing_session.attributes = params[:pairing_session]
      @pairing_session.enable_geocoding = true
      if @pairing_session.save
        redirect_to(pairing_sessions_path, :notice => 'Pairing session was successfully updated.')
      else
        render :edit
      end
    else
      raise ::Forbidden403Exception
    end
  end

  def destroy
    @pairing_session.destroy
    UserMailer.session_cancelled_email(@pairing_session).deliver if @pairing_session.pair.present?
    redirect_to(pairing_sessions_url, :notice => 'Pairing session was successfully deleted.')
  end

  def set_pair_on
    if @pairing_session.update_attributes(:pair => current_user)
      UserMailer.pair_found_for_session_email(@pairing_session).deliver
      redirect_to(pairing_sessions_path, :notice => 'You are the lucky winner. Have a good time.')
    else
      redirect_to(pairing_sessions_path, :alert => "Sorry but I couldn't set you are the pair for this session.")
    end
  end

  def remove_pair_from
    if @pairing_session.update_attributes(:pair => nil)
      UserMailer.pair_cancelled_for_session_email(@pairing_session).deliver
      redirect_to(pairing_sessions_path, :notice => 'Sorry to see you go. Maybe next time.')
    else
      redirect_to(pairing_sessions_path, :alert => "Sorry but I couldn't remove you as the pair for this session.")
    end
  end

private
  def build_pairing_session(attrs={})
    @pairing_session = current_user.owned_pairing_sessions.build(params[:pairing_session])
  end

  def find_pairing_session
    @pairing_session = PairingSession.find(params[:id])
  end
end
