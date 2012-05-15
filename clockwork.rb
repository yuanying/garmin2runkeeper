$:.unshift(File.dirname(__FILE__) + '/config')
require 'boot'
require 'clockwork'

module Clockwork
  every(1.hour, 'synchronize') do
    Synchronizer.run
  end
end
