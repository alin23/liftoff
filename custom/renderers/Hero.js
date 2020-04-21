import React from "react";

const Hero = () => {
  var today = (new Date()).toLocaleDateString("ro-RO", {weekday: "long", day: "numeric", month: "long"})
  return (<h1 className="date" id="header-date">
    {today}
  </h1>)
};

export default Hero;
