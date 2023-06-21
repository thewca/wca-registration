import { EventSelector } from '@thewca/wca-components'
import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { Button, TextArea } from 'semantic-ui-react'
import getCompetitionInfo from '../../../api/competition/get/get_competition_info'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/loadingMessage'
import styles from './panel.module.scss'

export default function RegistrationEditPanel({ registration }) {
  const [selectedEvents, setSelectedEvents] = useState(registration.event_ids)
  const [comment, setComment] = useState(registration.comment)
  const [heldEvents, setHeldEvents] = useState([])
  const [islLoading, setIsLoading] = useState(true)
  const { competition_id } = useParams()
  useEffect(() => {
    getCompetitionInfo(competition_id).then((competitionInfo) => {
      setHeldEvents(competitionInfo.event_ids)
      setIsLoading(false)
    })
  }, [competition_id])
  const handleEventSelection = (selectedEvents) => {
    setSelectedEvents(selectedEvents)
  }
  return islLoading ? (
    <div className={styles.panel}>
      <LoadingMessage />
    </div>
  ) : (
    <div className={styles.panel}>
      <EventSelector
        handleEventSelection={handleEventSelection}
        events={heldEvents}
        initialSelected={registration.event_ids}
        size="2x"
      />
      <TextArea
        onChange={(_, data) => setComment(data.value)}
        value={comment}
      />
      <Button
        onClick={() => {
          setMessage('Registration is being updated', 'basic')
          updateRegistration(localStorage.getItem('user_id'), competition_id, {
            eventIds: selectedEvents,
            comment,
          }).then((response) => {
            if (response.error) {
              setMessage(
                'Registration update failed with error: ' + response.error,
                'negative'
              )
            } else {
              setMessage('Registration update succeeded', 'positive')
            }
          })
        }}
      >
        Update Registration
      </Button>
    </div>
  )
}
