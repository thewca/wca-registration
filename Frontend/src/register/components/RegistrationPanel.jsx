import React, { useState } from 'react'
import submitEventRegistration from '../../api/registration/post/submit_registration'
import EventSelection from './EventSelection'
import styles from './panel.module.scss'

const EVENTS = ['222', '333', '444', '555', '666', '777']

export default function RegistrationPanel() {
  const [competitorID, setCompetitorID] = useState('2012ICKL01')
  const [competitionID, setCompetitionID] = useState('BudapestSummer2023')
  const [selectedEvents, setSelectedEvents] = useState([])

  const handleEventSelection = (selectedEvents) => {
    setSelectedEvents(selectedEvents)
  }
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
      <EventSelection
        handleEventSelection={handleEventSelection}
        events={EVENTS}
      />
      <button
        onClick={(_) =>
          submitEventRegistration(competitorID, competitionID, selectedEvents)
        }
      >
        Insert Registration
      </button>
    </div>
  )
}
