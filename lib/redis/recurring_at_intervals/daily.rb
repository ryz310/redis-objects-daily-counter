# frozen_string_literal: true

class Redis
  module RecurringAtIntervals
    module Daily
      private

      def redis_daily_field_key(date_or_time)
        date_key = date_or_time.strftime('%Y-%m-%d')
        [original_key, date_key].flatten.join(':')
      end

      def next_key(date, length = 1)
        date + length
      end
    end
  end
end
