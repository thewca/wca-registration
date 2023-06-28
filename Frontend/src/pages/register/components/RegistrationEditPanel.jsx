import { EventSelector } from '@thewca/wca-components'
import React, { useContext, useState } from 'react'
import { useParams } from 'react-router-dom'
import { Button, TextArea } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { setMessage } from '../../../ui/events/messages'
import styles from './panel.module.scss'

export default function RegistrationEditPanel({ registration }) {
  const [selectedEvents, setSelectedEvents] = useState(registration.event_ids)
  const [comment, setComment] = useState(registration.comment)
  const { competition_id } = useParams()
  const { competitionInfo } = useContext(CompetitionContext)
  return (
    <div className={styles.panel}>
      <EventSelector
        handleEventSelection={setSelectedEvents}
        events={competitionInfo.event_ids}
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
          updateRegistration(registration.user_id, competition_id, {
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
