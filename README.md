# rails_weather

This application lets you get a current forecast and a 5 day forecast

## Software versions
Ruby 3.3.6
Rails 8.0.1
Redis 5.3

## Weather provider
Weather data is requested from [WeatherAPI.com] (http://weatherapi.com). Sign up for an API key. They have a generous free plan.

## Configuration
Copy env.example to .env and add a weatherapi.com API key and a Google Maps API key with the Places API enabled.

## Redis
The Redis installation page is [here] (https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/). Start redis after installing using the default configuration.

## Tests
Use `rails test` to run the tests

## Address resolution
Enter an address to find a forecast. The address you enter must resolve to a U.S. postal code.

