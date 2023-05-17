import React, { useState } from 'react'
import submitEventRegistration from '../../api/registration/post/submit_registration'
import styles from './panel.module.scss'

const EVENTS = ['3x3', '4x4']

function toggleElementFromArray(arr, element) {
  const index = arr.indexOf(element)
  if (index !== -1) {
    arr.splice(index, 1)
  } else {
    arr.push(element)
  }
  return arr
}

function EventSelection({ events, setEvents }) {
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

export default function RegistrationPanel() {
  const [competitorID, setCompetitorID] = useState('2012ICKL01')
  const [competitionID, setCompetitionID] = useState('HessenOpen2023')
  const [events, setEvents] = useState([])

  return (
    <div className={styles.panel}>
      <label>
        Competitor_id
        <input
          type="text"
          value={competitorID}
          name="competitor_id"
          onChange={(e) => setCompetitorID(e.target.value)}
        />
      </label>
      <label>
        Competition_id
        <input
          type="text"
          value={competitionID}
          name="competition_id"
          onChange={(e) => setCompetitionID(e.target.value)}
        />
      </label>
      <EventSelection events={events} setEvents={setEvents}>
        {' '}
      </EventSelection>
      <button
        onClick={(_) =>
          submitEventRegistration(competitorID, competitionID, events)
        }
      >
        {' '}
        Insert Registration
      </button>
    </div>
  )
}
