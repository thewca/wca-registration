import React, { useState } from 'react'
import CubingIcon from './CubingIcon'
import './eventselection.scss'

// TODO move this to the WCA component library

export default function EventSelection({ handleEventSelection, events }) {
  const [selectedEvents, setSelectedEvents] = useState([])

  const handleEventToggle = (event) => {
    if (selectedEvents.includes(event)) {
      const new_events = selectedEvents.filter(
        (selectedEvent) => selectedEvent !== event
      )
      setSelectedEvents(new_events)
      handleEventSelection(new_events)
    } else {
      const new_events = [...selectedEvents, event]
      setSelectedEvents(new_events)
      handleEventSelection(new_events)
    }
  }
  return (
    <div className="event-selection-container">
      {events.map((wca_event) => (
        <label key={wca_event} className="event-label">
          <CubingIcon
            event={wca_event}
            selected={selectedEvents.includes(wca_event)}
            size="2x"
          />
          <input
            className="event-checkbox"
            type="checkbox"
            value="0"
            name={`event-${wca_event}`}
            onChange={(_) => handleEventToggle(wca_event)}
          />
        </label>
      ))}
    </div>
  )
}
