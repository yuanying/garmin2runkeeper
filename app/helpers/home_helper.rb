# Helper methods defined here can be accessed in any controller or view in the application

Garmin2runkeeper.helpers do
  def csrf_token
    Rack::Csrf.csrf_token(env)
  end

  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end

  def runkeeper_name
    @user.runkeeper_auth.info["name"].blank? ? @user.uid : @user.runkeeper_auth.info.name
  end

  def runkeeper_icon
    @user.runkeeper_auth.extra.raw_info.medium_picture || url('/img/runkeeper.jpg')
  end

  def valid_garmin_account?
    return false if @user.garmin_id.blank?
    return true if @user.recent_activities && @user.garmin_was_down
    return false if @user.recent_activities.size == 0
    return true
  end
end
