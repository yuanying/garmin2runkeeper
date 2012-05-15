require 'user'
require 'uri'
require 'runkeeper'

Runkeeper.configure do |config|
  config.client_id      = ENV['RUNKEEPER_CLIENT_ID']
  config.client_secret  = ENV['RUNKEEPER_CLIENT_SECRET']
end

if ENV['http_proxy']
  require 'runkeeper/connection'
  class Runkeeper
    class Connection
      HTTP_PROXY = URI.parse(ENV['http_proxy'])
      http_proxy HTTP_PROXY.host, HTTP_PROXY.port
    end
  end
end

class Runkeeper
  class Activity
    attr_accessor :heart_rate

    alias old_optional_attrs optional_attrs

    def optional_attrs
      h = {}
      [
        :total_distance,
        :average_heart_rate,
        :total_calories,
        :heart_rate,
        :notes,
        :path,
        :post_to_facebook,
        :post_to_twitter
      ].each do |method_name|
        v = send(method_name)
        h[method_name] = v if v
      end
      h
    end
  end
end

class GarminExporter

  def post user, activity_id, post_to_facebook, post_to_twitter
    type = 'Running'
    start_time = nil
    total_distance = 0
    duration = nil
    # average_heart_rate = 0
    heart_rate = []
    total_calories = 0
    notes = nil
    path = []

    open("http://connect.garmin.com/proxy/activity-service-1.1/gpx/activity/#{activity_id}?full=true") do |gpx|
      doc = REXML::Document.new gpx
      title =  doc.elements['/gpx/trk/name'] ? doc.elements['/gpx/trk/name'].text : 'Untitle'
      desc  = doc.elements['/gpx/trk/desc'] ? doc.elements['/gpx/trk/desc'].text : ''
      notes = "#{title}, #{desc}"
    end

    open("http://connect.garmin.com/proxy/activity-service-1.1/tcx/activity/#{activity_id}?full=true") do |tcx|
      doc = REXML::Document.new tcx

      doc.elements.each('/TrainingCenterDatabase/Activities/Activity/Lap') do |lap|

        if distance = lap.elements['DistanceMeters']
          distance = distance.text.to_i
          total_distance += distance
        end

        if calories = lap.elements['Calories']
          calories = calories.text.to_i
          total_calories += calories
        end

        trigger_method = trigger_method.text.downcase if trigger_method = lap.elements['TriggerMethod']

        lap.elements.each('Track/Trackpoint') do |tp|
          if time = tp.elements['Time']
            time = Time.parse(time.text)
            start_time = time unless start_time
            duration = time.to_i - start_time.to_i

            latitude = tp.elements['Position/LatitudeDegrees']
            longitude = tp.elements['Position/LongitudeDegrees']
            altitude = tp.elements['AltitudeMeters']
            trigger_method = trigger_method || 'manual'

            if  latitude && longitude && altitude
              wgs84 = {}
              wgs84[:timestamp] = duration
              wgs84[:latitude] = latitude.text
              wgs84[:longitude] = longitude.text
              wgs84[:altitude] = altitude.text
              wgs84[:type] = trigger_method
              path << wgs84
            end

            if hr_value = tp.elements['HeartRateBpm/Value']
              hr_value = hr_value.text.to_i
              hr = {}
              hr[:timestamp] = duration
              hr[:heart_rate] = hr_value
              heart_rate << hr
            end
          end
        end
      end
    end

    activity = user.runkeeper.new_activity(
      :type => type,
      :start_time => start_time.localtime,
      :duration => duration,
      :heart_rate => heart_rate,
      :path => path,
      :total_distance => total_distance,
      :total_calories => total_calories,
      :notes => notes,
      :post_to_facebook => post_to_facebook,
      :post_to_twitter => post_to_twitter
    )
    activity.save
  end
end

