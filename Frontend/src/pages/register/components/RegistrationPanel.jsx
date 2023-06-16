import { EventSelector } from '@thewca/wca-components'
import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { Message } from 'semantic-ui-react'
import getCompetitionInfo from '../../../api/competition/get/get_competition_info'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import getCompetitorInfo from '../../../api/user/get/get_user_info'
import styles from './panel.module.scss'

export default function RegistrationPanel() {
  const [competitorID, setCompetitorID] = useState('2012ICKL01')
  const [selectedEvents, setSelectedEvents] = useState([])
  const [message, setMessage] = useState({})
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
      {message.text ? (
        <Message
          negative={message.type === 'negative'}
          positive={message.type === 'positive'}
          className={styles.message}
        >
          {message.text}
        </Message>
      ) : (
        ''
      )}
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
        onClick={async () => {
          // TODO Remove this when we start reading user_id out of the jwt token
          const competitor_info = await getCompetitorInfo(competitorID)
          const response = await submitEventRegistration(
            competitor_info.user.id,
            competition_id,
            selectedEvents
          )
          if (response.error) {
            // TODO move this when I make a more general success/error component
            setMessage({
              text: 'Registration failed with error: ' + response.error,
              type: 'negative',
            })
          } else {
            setMessage({
              text: 'Registration succeeded',
              type: 'positive',
            })
          }
        }}
      >
        Insert Registration
      </button>
    </div>
  )
}
