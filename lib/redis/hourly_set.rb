# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/base_set_object"

class Redis
  class HourlySet < BaseSetObject
    def range(start_time, end_time)
      keys =
        (start_time.to_i..end_time.to_i)
        .step(3600)
        .map { |integer| redis_daily_field_key(Time.at(integer)) }
      redis.sunion(*keys).map { |v| unmarshal(v) }
    end

    private

    def redis_daily_field_key(time)
      time_key = time.strftime('%Y-%m-%dT%H')
      [original_key, time_key].flatten.join(':')
    end

    def next_key(time, length)
      time + 3600 * (length - 1)
    end
  end
end