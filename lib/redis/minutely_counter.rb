# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/base_counter_object"
require "#{File.dirname(__FILE__)}/recurring_at_intervals/minutely"

class Redis
  class MinutelyCounter < BaseCounterObject
    include Minutely
  end
end
