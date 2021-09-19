# frozen_string_literal: true

require 'redis/daily_counter'
class Redis
  module Objects
    module MonthlyCounters
      class << self
        def included(klass)
          klass.send :include, InstanceMethods
          klass.extend ClassMethods
        end
      end

      module ClassMethods
        def monthly_counter(name, options = {}) # rubocop:disable Metrics/MethodLength
          options[:start] ||= 0
          options[:type]  ||= (options[:start]).zero? ? :increment : :decrement
          redis_objects[name.to_sym] = options.merge(type: :counter)

          mod = Module.new do
            define_method(name) do
              Redis::MonthlyCounter.new(
                redis_field_key(name), redis_field_redis(name), redis_options(name)
              )
            end
          end

          if options[:global]
            extend mod

            # dispatch to class methods
            define_method(name) do
              self.class.public_send(name)
            end
          else
            include mod
          end
        end
      end

      # Instance methods that appear in your class when you include Redis::Objects.
      module InstanceMethods
      end
    end
  end
end