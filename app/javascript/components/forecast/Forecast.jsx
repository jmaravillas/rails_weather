import React from 'react';
import PropTypes from 'prop-types';
import './Forecast.css';


const Forecast = ({ currentWeather, forecastData, forecastCity }) => {
  if (!currentWeather || !forecastData) {
    return <div>Loading weather data...</div>;
  }

  return (
    <div className="forecast-container">
      <h2>Forecast for {forecastCity}</h2>
      {/* Current Weather Section */}
      <div className="current-weather">
        <h3>Current Weather</h3>
        <div className="weather-details">
          <div className="temperature">
            Temperature: {currentWeather.temp}°F
          </div>
          <div className="condition">
            Condition: {currentWeather.condition}
          </div>
        </div>
      </div>

      {/* Forecast Section */}
      <div className="forecast">
        <h3>5-Day Forecast</h3>
        <div className="forecast-list">
          {forecastData.map((day, index) => (
            <div key={index} className="forecast-item">
              <div className="date">Day: {day.date}</div>
              <div className="temp-high">High: {day.max_temp}°F</div>
              <div className="temp-low">Low: {day.min_temp}°F</div>
              <div className="condition">Condition: {day.condition}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

Forecast.propTypes = {
  currentWeather: PropTypes.shape({
    temp: PropTypes.number.isRequired,
    condition: PropTypes.string.isRequired,
  }),
  forecastData: PropTypes.arrayOf(
    PropTypes.shape({
      date: PropTypes.string.isRequired,
      max_temp: PropTypes.number.isRequired,
      min_temp: PropTypes.number.isRequired,
      condition: PropTypes.string.isRequired,
    })
  ),
};

export default Forecast;
