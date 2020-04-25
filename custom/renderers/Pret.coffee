import React from 'react'

Pret = ({ name, value, row = {} }) ->
  indisponibil = row.fields.filter((f) -> f.name == "Indisponibil")[0]?.value ? false
  if indisponibil
    return null if name != "Pret Minim"
    return <p className={"#{name} field #{ if indisponibil then "indisponibil" else "" }"}>Indisponibil</p>

  if name == "Pret Minim"
    <p className={"#{name} field"}><span>de la </span>{value} {if value == 1 then "leu" else "lei"}</p>
   else
    <p className={"#{name} field"}><span>la </span>{value} {if value == 1 then "leu" else "lei"}</p>

export default Pret