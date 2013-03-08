require 'set'
require 'yaml'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/dublincore'
require 'open-uri'
require 'omniauth/auth_hash'

class User
  attr_reader :garmin_was_down

  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :uid,                 :type => String
  field :garmin_id,           :type => String
  field :garmin_password,     :type => String
  field :post_to_twitter,     :type => Boolean, :default => false
  field :post_to_facebook,    :type => Boolean, :default => false
  field :already_sync_url,    :type => String
  field :already_sync_urls,   :type => Set
  field :raw_runkeeper_auth,  :type => String
  field :raw_timezone,        :type => String

  # You can define indexes on documents using the index macro:
  index :uid , :unique => true

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  def runkeeper_auth=(value)
    self.raw_runkeeper_auth = value.to_yaml
    @runkeeper_auth = value
  end

  def runkeeper_auth
    @runkeeper_auth ||= YAML.load(self.raw_runkeeper_auth)
    @runkeeper_auth
  end

  def timezone=(value)
    @timezone = ActiveSupport::TimeZone.new(value)
    self.raw_timezone = @timezone.name
  end

  def timezone
    @timezone ||= ActiveSupport::TimeZone.new(self.raw_timezone)
    @timezone
  rescue
    @timezone = ActiveSupport::TimeZone.new('Tokyo')
    @timezone
  end

  def rss_url
    garmin_username = self.garmin_id
    "http://connect.garmin.com/feed/rss/activities?feedname=Garmin#{Time.now.strftime('%Y%m%d%H')}&explore=true&activityType=running&eventType=all&activitySummarySumDistance-unit=kilometer&activitySummarySumDuration-unit=hour&activitySummaryGainElevation-unit=meter&owner=#{garmin_username}&sortField=beginTimestamp"
  end

  def activities_url
    "http://connect.garmin.com/activities"
  end

  def recent_activities
    unless defined?(@recent_activities)
      proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
      proxy = URI.parse(proxy) if proxy

      agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
      agent.set_proxy(proxy.host, proxy.port) if proxy
      page = agent.get('http://connect.garmin.com/signin')
      form = page.form('login')
      form.send('login:loginUsernameField', self.garmin_id)
      form.send('login:password', self.garmin_password)
      form.submit

      @recent_activities = []
      page = agent.get(activities_url, { 'activityType' => 'running', 'eventType' => 'all'})
      activities = page.search('.activityNameLink')
      activities.each do |act|
        act[:href].match(/\/([\d]+)$/)
        @recent_activities << "http://connect.garmin.com/activity/#{$1}"
      end
    end
    @recent_activities
  rescue
    @garmin_was_down = true
    @recent_activities = []
    @recent_activities
  end

  def recent_public_activities
    @recent_public_activities ||= open(rss_url) do |io|
      items = []
      rss = RSS::Parser.parse(io.read)
      raise 'RSS Error' if rss.channel.description.index('Error')
      rss.items.each do |item|
        items << item unless item.link.nil?
      end
      items
    end
    @recent_public_activities
  rescue
    @garmin_was_down = true
    @recent_public_activities = []
    @recent_public_activities
  end

  def unsynchronized_activities
    unless @unsynchronized_activities
      @unsynchronized_activities = []
      recent_public_activities.each do |item|
        break if item.link == self.already_sync_url
        @unsynchronized_activities << item
      end
      @unsynchronized_activities.reverse!
    end
    @unsynchronized_activities
  end

  def sync exporter
    return unless self.garmin_id
    unsynchronized_activities.each do |item|
      activity_id = item.link.split('/').last
      exporter.post(self, activity_id, self.post_to_facebook, self.post_to_twitter)

      self.already_sync_url = item.link
      self.save!
    end
  end

  def runkeeper
    require 'runkeeper'
    @runkeeper ||= Runkeeper.new(self.runkeeper_auth.credentials.token)
    @runkeeper
  end

  def check_account!
    self.runkeeper.profile
  end

end
