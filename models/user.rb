class User
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :uid, :type => String
  field :garmin_id, :type => String
  field :post_to_twitter, :type => Boolean
  field :post_to_facebook, :type => Boolean
  field :already_sync_url, :type => String
  field :raw_runkeeper_auth, :type => Text

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>
end
