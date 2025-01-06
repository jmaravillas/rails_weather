require "rest-client"
require "json"

CACHE_TTL_SECONDS = 30 * 60
WEATHER_BASE_URL = ENV.fetch("WEATHER_API_URL")
WEATHER_API_KEY = ENV.fetch("WEATHER_API_KEY")
FORECAST_DAYS = 5
HOUR = 0 # hour of the day to request

class WeatherController < ApplicationController
  def index
  end

  def forecast
    postal_code = params.require(:postal_code)
    # check redis for the postal code
    cached_forecast = REDIS_CLIENT.get(postal_code)

    if cached_forecast
      Rails.logger.debug("Postal code: #{postal_code} found in redis")
      resp = JSON.parse(cached_forecast)
    else
      begin
        resp = forecast_response(JSON.parse(forecast_request(postal_code)))
      rescue StandardError => e
        Rails.logger.error("Forecast error: #{e.message}")
        return render json: { error: "Unable to fetch weather forecast" }, status: :internal_server_error
      end
      # cache the forecast in redis for 30 minutes
      REDIS_CLIENT.setex("#{postal_code}", CACHE_TTL_SECONDS, resp.to_json)
    end

    Rails.logger.debug("forecast response: #{resp}")
    render json: resp
  end

  private

  # Request the current and 5 day forecast from the weather provider
  def forecast_request(postal_code)
    options = {
      params: {
        key: WEATHER_API_KEY,
        q: postal_code,
        days: FORECAST_DAYS,
        hour: HOUR
      }
    }
    response = RestClient.get(WEATHER_BASE_URL, options)
    Rails.logger.debug("Response: #{response.code}, #{JSON.parse(response.body)}")
      # if response.code != 200
      raise StandardError.new "There was a problem requesting the forecast"
    # end
    response
  end

  # Create a hash of the forecast data we're interested in
  def forecast_response(json_response)
    forecast_days = json_response["forecast"]["forecastday"]
    {
      city: json_response["location"]["name"],
      state: json_response["location"]["region"],
      current: {
        temp: json_response["current"]["temp_f"],
        condition: json_response["current"]["condition"]["text"]
      },
      forecast: forecast_days.map { |day| {
        date: day["date"],
        max_temp: day["day"]["maxtemp_f"],
        min_temp: day["day"]["mintemp_f"],
        condition: day["day"]["condition"]["text"]
      }}
    }
  end
end
