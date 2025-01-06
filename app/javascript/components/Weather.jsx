import React, { useRef, useEffect } from "react";
import Forecast from "./forecast/Forecast";

export default () => {
  const inputRef = useRef(null);
  const postalCodeRef = useRef(null);
  // Add state for error when a postal code is not available
  const [hasError, setHasError] = React.useState(false);

  // API request error
  const [hasRequestError, setHasRequestError] = React.useState(false);

  // handle weather forecast data
  const [hasForecastData, setHasForecastData] = React.useState(false);
  const [forecastData, setForecastData] = React.useState(null);
  const [currentWeather, setCurrentWeather] = React.useState(null);
  const [forecastCity, setForecastCity] = React.useState(null);

  useEffect(() => {
    // Initialize Google Places Autocomplete
    const autocomplete = new window.google.maps.places.Autocomplete(inputRef.current, {
      types: ['address'],
      componentRestrictions: { country: 'us' } // Optional: restrict to US addresses
    });

    // Handle place selection
    autocomplete.addListener('place_changed', () => {
      const place = autocomplete.getPlace();
      const components = place.address_components;
      let postal_code = "";
      for (const component of place.address_components) {
        const componentType = component.types[0];
        // get just the postal code
        switch (componentType) {
          case "postal_code": {
            postal_code = `${component.long_name}`;
            postalCodeRef.current.value = postal_code;
            break;
          }
        }
      }
      if (postal_code === "") {
        setHasError(true);
      } else {
        setHasError(false);
      }
    });
  }, []);

  const handleSubmit = (e) => {
    e.preventDefault();
    const postal_code = postalCodeRef.current.value;

    // initialize display and data
    setHasRequestError(false);
    setForecastData(null);
    setCurrentWeather(null);

    // Send POST request to weather forecast endpoint
    fetch('/forecast', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ postal_code })
    })
      .then(response => response.json())
      .then(data => {
        setHasForecastData(true);
        setForecastData(data.forecast);
        setCurrentWeather(data.current);
        setForecastCity(data.city);
      })
      .catch((error) => {
        console.error('Error:', error);
        setHasRequestError(true);
      });
  }

  return (
    <div className="vw-100 vh-100 primary-color d-flex flex-column">
      <div className="p-4 w-75">
        <h2>Get current weather conditions and a 5 day forecast</h2>
        <form className="mb-4" onSubmit={handleSubmit}>
          <div className="form-group">
            <input
              ref={inputRef}
              type="text"
              className={`form-control mb-2 w-100 ${hasError ? 'is-invalid' : ''}`}
              placeholder="Enter a US address"
              aria-label="Address"
            />
            {hasError && (
              <div className="invalid-feedback">
                Enter an address that resolves to a postal code
              </div>
            )}
            <input
              ref={postalCodeRef}
              type="hidden"
              name="postal_code"
            />
          </div>
          <button type="submit" className="btn btn-primary">
            Submit
          </button>
        </form>
        {hasRequestError && (
          <div className="invalid-feedback">
            Error returning the forecast. Please try again later.
          </div>
        )}
        {hasForecastData && (
          <Forecast
            currentWeather={currentWeather}
            forecastData={forecastData}
            forecastCity={forecastCity}
          />
        )}
      </div>
    </div>
  );
};