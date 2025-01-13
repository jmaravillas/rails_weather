require "test_helper"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  def setup
      # unless defined?(REDIS_CLIENT)
      @redis_mock = Minitest::Mock.new
      Object.const_set("REDIS_CLIENT", @redis_mock)
    # end

    @postal_code = "12345"
    @weather_response = {
      "city" => "Berkeley",
      "state" => "California",
      "current" => {
        "temp_f" => 66.0,
        "condition" => {
          "text" => "Sunny"
        }
      },
      "forecast" => {
        "forecastday" => [
          {
            "date" => "2024-03-20",
            "day" => {
              "maxtemp_f" => 77.0,
              "mintemp_f" => 55.0,
              "condition" => {
                "text" => "Partly cloudy"
              }
            }
          }
        ]
      }
    }
  end

  test "should get index" do
    get weather_index_url
    assert_response :success
  end

  test "should return cached forecast data" do
    RestClient.stubs(:get).returns(@weather_response.to_json)
    # allow(RestClient).to receive(:get).and_return(@weather_response.to_json)
    REDIS_CLIENT.expect :get, @weather_response.to_json, [ @postal_code ]

    post forecast_url, params: { postal_code: @postal_code }

    assert_response :success
    response_body = JSON.parse(@response.body)
    assert_equal "Berkeley", response_body["city"]
    assert_equal "California", response_body["state"]

    REDIS_CLIENT.verify
  end

  test "should fetch and cache new forecast data" do
    # RestClient.stubs(:get).returns(@weather_response.to_json)
    REDIS_CLIENT.expect :get, nil, [ @postal_code ]
    REDIS_CLIENT.expect :setex, nil, [ @postal_code, 1800, @weather_response.to_json ]

    successful_response = Minitest::Mock.new
    successful_response.expect :code, 200
    successful_response.expect :body, @weather_response.to_json

    RestClient.stub :get, successful_response do
      post forecast_url, params: { postal_code: @postal_code }

      assert_response :success
      response_body = JSON.parse(@response.body)
      assert_equal "Berkeley", response_body["city"]
      assert_equal "California", response_body["state"]
      assert_equal 66.0, response_body.dig("current", "temp")
      assert_equal "Sunny", response_body.dig("current", "condition")
    end

    forecast_url.verify
    successful_response.verify
  end

  test "should handle API errors gracefully" do
    REDIS_CLIENT.expect :get, nil, [ @postal_code ]

    RestClient.stub :get, ->(*_args) { raise StandardError.new("There was a problem requesting the forecast") } do
      post forecast_url, params: { postal_code: @postal_code }

      assert_response :internal_server_error
      response_body = JSON.parse(response.body)
      assert_equal "Unable to fetch weather forecast", response_body["error"]
    end

    REDIS_CLIENT.verify
  end
end
