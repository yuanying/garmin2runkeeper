
# Connection.new takes host, port
host = ENV['MONGODB_HOST'] || 'localhost'
port = ENV['MONGODB_PORT'] || Mongo::Connection::DEFAULT_PORT

database_name = case Padrino.env
  when :development then 'garmin2runkeeper_development'
  when :production  then 'garmin2runkeeper_production'
  when :test        then 'garmin2runkeeper_test'
end

Mongoid.database = Mongo::Connection.new(host, port).db(database_name) unless Padrino.env == :test

# You can also configure Mongoid this way
# Mongoid.configure do |config|
#   name = @settings["database"]
#   host = @settings["host"]
#   config.master = Mongo::Connection.new.db(name)
#   config.slaves = [
#     Mongo::Connection.new(host, @settings["slave_one"]["port"], :slave_ok => true).db(name),
#     Mongo::Connection.new(host, @settings["slave_two"]["port"], :slave_ok => true).db(name)
#   ]
# end
#
# More installation and setup notes are on http://mongoid.org/docs/
