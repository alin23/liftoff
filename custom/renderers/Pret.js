import React from 'react'

const Pret = ({ name, value }) => {
  if (name == "Pret Minim") {
    return <p className={name}><span>de la </span>{value} lei</p>;
  } else {
    return <p className={name}><span>la </span>{value} lei</p>;
  }
};

export default Pret;