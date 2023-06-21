import { EventSelector } from '@thewca/wca-components'
import React, { useState } from 'react'
import { useParams } from 'react-router-dom'
import { Button, TextArea } from 'semantic-ui-react'
import { useHeldEvents } from '../../../api/helper/hooks'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/loadingMessage'
import styles from './panel.module.scss'

export default function RegistrationPanel() {
  const [selectedEvents, setSelectedEvents] = useState([])
  const { competition_id } = useParams()
  const { isLoading, heldEvents } = useHeldEvents(competition_id)
  const [comment, setComment] = useState('')
  const handleEventSelection = (selectedEvents) => {
    setSelectedEvents(selectedEvents)
  }
  return isLoading ? (
    <div className={styles.panel}>
      <LoadingMessage />
    </div>
  ) : (
    <div className={styles.panel}>
      <EventSelector
        handleEventSelection={handleEventSelection}
        events={heldEvents}
        initialSelected={[]}
        size="2x"
      />
      <TextArea onChange={(_, data) => setComment(data.value)}> </TextArea>
      <Button
        onClick={async () => {
          setMessage('Registration is being processed', 'basic')
          const response = await submitEventRegistration(
            localStorage.getItem('user_id'),
            competition_id,
            comment,
            selectedEvents
          )
          if (response.error) {
            setMessage(
              'Registration failed with error: ' + response.error,
              'negative'
            )
          } else {
            setMessage('Registration succeeded', 'positive')
          }
        }}
        positive
      >
        Register
      </Button>
    </div>
  )
}
