import { EventSelector } from '@thewca/wca-components'
import React, { useContext, useEffect, useState } from 'react'
import { Button, Checkbox, TextArea } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './editor.module.scss'
import { useQuery } from '@tanstack/react-query'
import getCompetitorInfo from '../../../api/user/get/get_user_info'
import { AuthContext } from '../../../api/helper/context/auth_context'

export default function RegistrationEditor() {
  const { user } = useContext(AuthContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const [comment, setComment] = useState('')
  const [status, setStatus] = useState('')
  const [selectedEvents, setSelectedEvents] = useState([])
  const [registration, setRegistration] = useState({})
  const { data: serverRegistration } = useQuery({
    queryKey: [competitionInfo.id, user],
    queryFn: () => getSingleRegistration(user, competitionInfo.id),
  })
  const { isLoading, data: competitorInfo } = useQuery({
    queryKey: ['info', user],
    queryFn: () => getCompetitorInfo(user),
  })

  useEffect(() => {
    if (serverRegistration) {
      setRegistration(serverRegistration.registration)
      setComment(serverRegistration.registration.comment)
      setStatus(serverRegistration.registration.registration_status)
      setSelectedEvents(serverRegistration.registration.event_ids)
    }
  }, [serverRegistration])

  return (
    <div className={styles.editor}>
      {!registration.registration_status || isLoading ? (
        <LoadingMessage />
      ) : (
        <div>
          <h2>{competitorInfo.user.name}</h2>
          <EventSelector
            handleEventSelection={(events) => {
              setSelectedEvents(events)
            }}
            initialSelected={registration.event_ids}
            events={competitionInfo.event_ids}
            size="2x"
          />
          <h3> Comment </h3>
          <TextArea
            value={comment}
            onChange={(_, data) => {
              setComment(data.value)
            }}
          />
          <h3> Status </h3>
          <Checkbox
            radio
            label="Accepted"
            name="checkboxRadioGroup"
            value="accepted"
            checked={status === 'accepted'}
            onChange={(_, data) => setStatus(data.value)}
          />
          <br />
          <Checkbox
            radio
            label="Waiting"
            name="checkboxRadioGroup"
            value="waiting"
            checked={status === 'waiting'}
            onChange={(_, data) => setStatus(data.value)}
          />
          <br />
          <Checkbox
            radio
            label="Deleted"
            name="checkboxRadioGroup"
            value="deleted"
            checked={status === 'deleted'}
            onChange={(_, data) => setStatus(data.value)}
          />
          <br />
          <Button
            onClick={() => {
              setMessage('Updating Registration', 'basic')
              updateRegistration(user_id, competition_id, {
                status,
                eventIds: selectedEvents,
                comment,
              }).then((response) => {
                if (response.error) {
                  setMessage(
                    'Updating Registration failed with error: ' +
                      response.error,
                    'negative'
                  )
                } else {
                  setMessage('Successfully updated Registration', 'positive')
                  setRegistration(response.registration)
                }
              })
            }}
          >
            Update Registration
          </Button>
        </div>
      )}
    </div>
  )
}
