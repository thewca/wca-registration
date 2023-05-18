import React from 'react'
import styles from './panel.module.scss'

function toggleElementFromArray(arr, element) {
  const index = arr.indexOf(element)
  if (index !== -1) {
    arr.splice(index, 1)
  } else {
    arr.push(element)
  }
  return arr
}

const EVENTS = ['3x3', '4x4']

export default function EventSelection({ events, setEvents }) {
  return (
    <div className={styles.events}>
      {EVENTS.map((wca_event) => (
        <label key={wca_event}>
          {wca_event}
          <input
            type="checkbox"
            value="0"
            name={`event-${wca_event}`}
            onChange={(_) =>
              setEvents(toggleElementFromArray(events, wca_event))
            }
          />
        </label>
      ))}
    </div>
  )
}
