Garmin2runkeeper.controllers :home do
  layout :home

  # get :index, :map => "/foo/bar" do
  #   session[:foo] = "bar"
  #   render 'index'
  # end

  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get "/example" do
  #   "Hello world!"
  # end

  get :index, :map => '/' do
    return render 'home/index' unless @user

    return render 'home/home'
  end

  post :index, :map => '/' do
    return redirect to('/') unless @user

    if params['delete']
      @user.destroy
      flash[:notice] = 'User information was deleted!'
    elsif params['logout']
      session[:user] = nil
      flash[:notice] = 'Logout successfully.'
    else
      garmin_id = params['garmin_id'].split(//u)[0, 40].join
      garmin_id = nil if garmin_id.nil? || garmin_id.empty?
      @user.garmin_id         = garmin_id
      @user.post_to_facebook  = params['post_to_facebook'] ? true : false
      @user.post_to_twitter   = params['post_to_twitter']  ? true : false
      @user.save!
      flash[:notice] = 'Update informations successfully!'
    end
    redirect to('/')
  end

  get :public_activities, :map => '/public_activities' do
    return '' unless @user
    render 'home/public_activities', :layout => false
  end

  get :auth_callback, :map => '/auth/:name/callback' do
    auth = request.env['omniauth.auth']
    user = User.find_or_create_by(:uid => auth.uid)
    user.runkeeper_auth = auth
    user.save!
    
    session[:user] = user.uid
    redirect to('/')
  end

end
