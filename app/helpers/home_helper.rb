# Helper methods defined here can be accessed in any controller or view in the application

Garmin2runkeeper.helpers do
  def csrf_token
    Rack::Csrf.csrf_token(env)
  end

  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end
end
