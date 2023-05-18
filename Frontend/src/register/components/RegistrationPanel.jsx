import React, { useState } from 'react'
import submitEventRegistration from '../../api/registration/post/submit_registration'
import EventSelection from './EventSelection'
import styles from './panel.module.scss'

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
      <EventSelection events={events} setEvents={setEvents} />
      <button
        onClick={(_) =>
          submitEventRegistration(competitorID, competitionID, events)
        }
      >
        Insert Registration
      </button>
    </div>
  )
}
