module UserGC
  def self.run

    User.all.each do |user|
      begin
        puts "#{user.uid}: #{user.runkeeper_auth.info.name}"
        user.check_account!
      rescue => ex
        puts "invalid account..."
        user.destroy
        puts "deleted."
      end
    end
  end
end
