$:.unshift(File.dirname(__FILE__) + '/config')
require 'boot'
require 'clockwork'

Clockwork.every 1.hour, 'synchronize' do
  Synchronizer.run
end
Clockwork.run
