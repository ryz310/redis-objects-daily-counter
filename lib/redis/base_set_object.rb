# frozen_string_literal: true

class Redis
  module BaseSetObject
    private

    def get_redis_object(key)
      Redis::Set.new(key)
    end

    def get_value_from_redis(key)
      vals = redis.smembers(key)
      vals.nil? ? [] : vals.map { |v| unmarshal(v) }
    end

    def get_values_from_redis(keys)
      redis.sunion(*keys).map { |v| unmarshal(v) }
    end

    def delete_from_redis(key)
      redis.del(key)
    end

    def empty_value
      []
    end
  end
end
