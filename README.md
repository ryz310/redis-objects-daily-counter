[![CircleCI](https://circleci.com/gh/ryz310/redis-object-daily-counter.svg?style=svg)](https://circleci.com/gh/ryz310/redis-object-daily-counter) [![Gem Version](https://badge.fury.io/rb/redis-object-daily-counter.svg)](https://badge.fury.io/rb/redis-object-daily-counter) [![Maintainability](https://api.codeclimate.com/v1/badges/3639d1776e23031b1b31/maintainability)](https://codeclimate.com/github/ryz310/redis-object-daily-counter/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/3639d1776e23031b1b31/test_coverage)](https://codeclimate.com/github/ryz310/redis-object-daily-counter/test_coverage) [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=ryz310/redis-object-daily-counter)](https://dependabot.com)

# Redis::Objects::Daily::Counter

This is a gem which extends [Redis::Objects](https://github.com/nateware/redis-objects) gem.

Once install this gem, you can use the daily counter, etc. in addition to the standard features of Redis::Objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redis-object-daily-counter'
```

If you want to know about installation and standard usage, please see Redis::Objects' GitHub page.

## Usage

For illustration purposes, consider this stub class:

```rb
class Homepage
  include Redis::Objects

  daily_counter :pv_count

  def id
    1
  end
end

# 2021-04-01
hp = Homepage.new
hp.id # 1

hp.pv_count.increment
hp.pv_count.increment
hp.pv_count.increment
puts hp.pv_count.value # 3

# 2021-04-02 (next day)
puts hp.pv_count.value # 0
hp.pv_count.increment
hp.pv_count.increment
puts hp.pv_count.value # 2

start_date = Date.new(2021, 4, 1)
end_date = Date.new(2021, 4, 2)
hp.pv_count.range(start_date, end_date) # [3, 2]
```

The daily counter automatically switches the save destination when the date changes.
You can access past dates counted values like Ruby arrays:

```rb
# 2021-04-01
hp.pv_count.increment(3)

# 2021-04-02 (next day)
hp.pv_count.increment(2)

# 2021-04-03 (next day)
hp.pv_count.increment(5)

hp.pv_count[Date.new(2021, 4, 1)] # => 3
hp.pv_count[Date.new(2021, 4, 1), 3] # => [3, 2, 5]
hp.pv_count[Date.new(2021, 4, 1)..Date.new(2021, 4, 2)] # => [3, 2]

hp.pv_count.delete(Date.new(2021, 4, 1))
hp.pv_count.range(Date.new(2021, 4, 1), Date.new(2021, 4, 3)) # => [0, 2, 5]
hp.pv_count.at(Date.new(2021, 4, 2)) # => 2
```

### Timezone

This gem follows Ruby process' time zone, but if you extends Time class by ActiveSupport (e.g. `Time.current`), follows Rails process' timezone.

## Development

The development environment for this gem is configured with docker-compose.
Please use the following command:

    $ docker-compose up -d
    $ docker-compose run --rm ruby bundle
    $ docker-compose run --rm ruby rspec .
    $ docker-compose run --rm ruby rubocop -a

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/redis-object-daily-counter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/redis-object-daily-counter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Redis::Objects::Daily::Counter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/redis-object-daily-counter/blob/master/CODE_OF_CONDUCT.md).
