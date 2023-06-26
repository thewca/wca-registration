import { EventSelector } from '@thewca/wca-components'
import React, { useEffect, useState } from 'react'
import { Button, Checkbox, TextArea } from 'semantic-ui-react'
import useCompetitorInfo from '../../../api/helper/hooks/use_competitor_info'
import useHeldEvents from '../../../api/helper/hooks/use_held_events'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/loadingMessage'
import styles from './editor.module.scss'

export default function RegistrationEditor({ user_id, competition_id }) {
  const { isLoading: eventsLoading, heldEvents } = useHeldEvents(competition_id)
  const { isLoading: infoLoading, competitorInfo } = useCompetitorInfo(user_id)
  const [registration, setRegistration] = useState({})
  const [comment, setComment] = useState('')
  const [status, setStatus] = useState('')
  const [selectedEvents, setSelectedEvents] = useState([])

  useEffect(() => {
    getSingleRegistration(user_id, competition_id).then((response) => {
      const registration = response.registration
      setRegistration(registration)
      setComment(registration.comment)
      setStatus(registration.registration_status)
      setSelectedEvents(registration.event_ids)
    })
  }, [user_id, competition_id])

  return (
    <div className={styles.editor}>
      {!registration.registration_status || infoLoading || eventsLoading ? (
        <LoadingMessage />
      ) : (
        <div>
          <h2>{competitorInfo.user.name}</h2>
          <EventSelector
            handleEventSelection={(events) => {
              setSelectedEvents(events)
            }}
            initialSelected={registration.event_ids}
            events={heldEvents}
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
