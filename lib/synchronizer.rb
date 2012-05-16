module Synchronizer
  def self.run
    exporter = GarminExporter.new

    User.excludes(:garmin_id => nil).all.each do |user|
      begin
        puts "#{user.uid}: #{user.runkeeper_auth.info.name}"
        user.sync(exporter)
      rescue => ex
        p ex
      end
    end
  end
end