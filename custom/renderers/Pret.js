import React from 'react'

const Pret = ({ name, value }) => {
  if (name == "Pret Minim") {
    return <p className={`${name} field`}><span>de la </span>{value} {value == 1 ? "leu" : "lei"}</p>;
  } else {
    return <p className={`${name} field`}><span>la </span>{value} {value == 1 ? "leu" : "lei"}</p>;
  }
};

export default Pret;