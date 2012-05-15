module Synchronizer
  def self.run
    exporter = GarminExporter.new

    User.excludes(:garmin_id => nil).all.each do |user|
      begin
        user.sync(exporter)
      rescue => ex
        p ex
      end
    end
  end
end