import { EventSelector } from '@thewca/wca-components'
import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { Button, Message, TextArea } from 'semantic-ui-react'
import getCompetitionInfo from '../../../api/competition/get/get_competition_info'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import LoadingMessage from '../../shared/loadingMessage'
import styles from './panel.module.scss'

export default function RegistrationPanel() {
  const [selectedEvents, setSelectedEvents] = useState([])
  const [message, setMessage] = useState({})
  const [heldEvents, setHeldEvents] = useState([])
  const [islLoading, setIsLoading] = useState(true)
  const [comment, setComment] = useState('')
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
      <EventSelector
        handleEventSelection={handleEventSelection}
        events={heldEvents}
        initialSelected={[]}
        size="2x"
      />
      <TextArea onChange={(_, data) => setComment(data.value)}> </TextArea>
      <Button
        onClick={async () => {
          setMessage({
            text: 'Registration is being processed',
            type: 'basic',
          })
          const response = await submitEventRegistration(
            localStorage.getItem('user_id'),
            competition_id,
            comment,
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
        positive
      >
        Register
      </Button>
    </div>
  )
}
