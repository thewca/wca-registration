import { EventSelector } from '@thewca/wca-components'
import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import getCompetitionInfo from '../../../api/competition/get/get_competition_info'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import styles from './panel.module.scss'

export default function RegistrationPanel() {
  const [competitorID, setCompetitorID] = useState('2012ICKL01')
  const [selectedEvents, setSelectedEvents] = useState([])
  const [heldEvents, setHeldEvents] = useState([])
  const { competition_id } = useParams()
  useEffect(() => {
    getCompetitionInfo(competition_id).then((competitionInfo) => {
      setHeldEvents(competitionInfo.event_ids)
    })
  }, [competition_id])
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
      <EventSelector
        handleEventSelection={handleEventSelection}
        events={heldEvents}
        initialSelected={[]}
        size="2x"
      />
      <button
        onClick={() =>
          submitEventRegistration(competitorID, competition_id, selectedEvents)
        }
      >
        Insert Registration
      </button>
    </div>
  )
}
