import React from "react"

Hero = () ->
  today = (new Date()).toLocaleDateString("ro-RO", {weekday: "long", day: "numeric", month: "long"})

  <h1 className="date" id="header-date">
    {today}
  </h1>

export default Hero
