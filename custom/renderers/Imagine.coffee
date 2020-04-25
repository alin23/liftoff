import React from 'react'

Imagine = ({ name, value, row = {} }) ->
  indisponibil = row.fields.filter((f) -> f.name == "Indisponibil")[0]?.value ? false
  return null if not value?[0]

  attachment = value[0]
  return null if not attachment.type.includes("image")
  src = attachment.url
  <div className={"attachments field #{name} #{ if indisponibil then "indisponibil" else "" }"}>
    <img
      key={attachment.id}
      src={src}
      className="attachment-image"
      alt={name}
    />
  </div>

export default Imagine