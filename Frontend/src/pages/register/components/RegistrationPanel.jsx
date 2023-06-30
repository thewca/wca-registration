import { EventSelector } from '@thewca/wca-components'
import React, { useContext, useState } from 'react'
import { Button, TextArea } from 'semantic-ui-react'
import { AuthContext } from '../../../api/helper/context/auth_context'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import { setMessage } from '../../../ui/events/messages'
import styles from './panel.module.scss'

export default function RegistrationPanel() {
  const { user } = useContext(AuthContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const [comment, setComment] = useState('')
  const [selectedEvents, setSelectedEvents] = useState([])
  return (
    <div className={styles.panel}>
      <EventSelector
        handleEventSelection={setSelectedEvents}
        events={competitionInfo.event_ids}
        initialSelected={[]}
        size="2x"
      />
      <TextArea onChange={(_, data) => setComment(data.value)}> </TextArea>
      <Button
        onClick={async () => {
          setMessage('Registration is being processed', 'basic')
          const response = await submitEventRegistration(
            user,
            competitionInfo.id,
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
