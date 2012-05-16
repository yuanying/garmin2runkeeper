$:.unshift(File.dirname(__FILE__) + '/config')

require 'fileutils'
require 'boot'
require 'clockwork'

class ClockworkDaemon < DaemonSpawn::Base

  def start args
    puts 'Started ClockworkDaemon'
    Clockwork.every 1.hour, 'synchronize' do
      Synchronizer.run
    end
    Clockwork.run
  end
end

pids_dir = File.join(File.dirname(__FILE__), 'tmp', 'pids')
log_dir = File.join(File.dirname(__FILE__), 'log')

FileUtils.mkdir_p(pids_dir) unless File.directory?(pids_dir)
FileUtils.mkdir_p(log_dir) unless File.directory?(log_dir)

ClockworkDaemon.spawn!(
  :working_dir => File.expand_path(File.dirname(__FILE__)),
  :pid_file => File.expand_path(File.join(pids_dir, 'clock.pid')),
  :log_file => File.expand_path(File.join(log_dir, 'clock.log')),
  :sync_log => true,
  :singleton => true
)
