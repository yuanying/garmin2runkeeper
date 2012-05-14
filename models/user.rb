require 'yaml'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/dublincore'
require 'open-uri'
require 'omniauth/auth_hash'

class User
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :uid, :type => String
  field :garmin_id, :type => String
  field :post_to_twitter, :type => Boolean, :default => false
  field :post_to_facebook, :type => Boolean, :default => false
  field :already_sync_url, :type => String
  field :raw_runkeeper_auth, :type => String

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

  def rss_url
    garmin_username = self.garmin_id
    "http://connect.garmin.com/feed/rss/activities?feedname=Garmin#{Time.now.strftime('%Y%m%d%H')}&explore=true&activityType=running&eventType=all&activitySummarySumDistance-unit=kilometer&activitySummarySumDuration-unit=hour&activitySummaryGainElevation-unit=meter&owner=#{garmin_username}&sortField=beginTimestamp"
  end

  def recent_public_activities
    open(rss_url) do |io|
      items = []
      RSS::Parser.parse(io.read).items.each do |item|
        items << item unless item.link.nil?
      end
      items
    end
  end

  def unsynchronized_activities
    items = []
    recent_public_activities.each do |item|
      break if item.link == self.already_sync_url
      items << item
    end
    items.reverse
  end

  def sync exporter
    return unless self.garmin_id
    unsynchronized_activities.each do |item|
      exporter.post(self, item, self.post_to_facebook, self.post_to_twitter)

      self.already_sync_url = item.link
      self.save!
    end
  end

  def runkeeper
    require 'runkeeper'
    @runkeeper ||= Runkeeper.new(self.auth.credentials.token)
    @runkeeper
  end

end
