import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Weather from "../components/Weather";

export default (
  <Router>
    <Routes>
      <Route path="/" element={<Weather />} />
    </Routes>
  </Router>
);