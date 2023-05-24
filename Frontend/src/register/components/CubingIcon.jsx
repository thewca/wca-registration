import './icons.scss'
import React from 'react'

//TODO move this to the WCA-component Library

export default function CubingIcon({ event, selected, size = "1x" }) {
  return (
    <i
      className={`icon cubing-icon event-${event} cubing-icon-${size}`}
      style={{ color: `${selected ? 'rgb(0, 0, 0)' : 'rgb(204, 204, 204)'}` }}
    />
  )
}
