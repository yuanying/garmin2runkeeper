source :rubygems

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'
gem 'rack_csrf', :require => 'rack/csrf'

# Component requirements
gem 'sass'
gem 'erubis', "~> 2.7.0"
gem 'mongoid'
gem 'bson_ext', :require => "mongo"

# Test requirements
gem 'rspec', :group => "test"
gem 'rack-test', :require => "rack/test", :group => "test"

# Padrino Stable Gem
gem 'padrino', '0.10.6'

gem 'runkeeper'
gem 'omniauth-runkeeper'

gem 'clockwork'

group :production, :staging do
  gem 'thin'
end

# Or Padrino Edge
# gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.10.6'
# end
