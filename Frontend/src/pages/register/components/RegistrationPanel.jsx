import { EventSelector } from '@thewca/wca-components'
import React, { useContext, useEffect, useState } from 'react'
import { Button, TextArea } from 'semantic-ui-react'
import { AuthContext } from '../../../api/helper/context/auth_context'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import { setMessage } from '../../../ui/events/messages'
import styles from './panel.module.scss'
import { useMutation, useQuery } from '@tanstack/react-query'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import LoadingMessage from '../../../ui/messages/loadingMessage'

export default function RegistrationPanel() {
  const { user } = useContext(AuthContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const [comment, setComment] = useState('')
  const [selectedEvents, setSelectedEvents] = useState([])
  const [registration, setRegistration] = useState({})
  const { data: registrationRequest, isLoading } = useQuery({
    queryKey: ['registration', user, competitionInfo.id],
    queryFn: () => getSingleRegistration(user, competitionInfo.id),
  })
  useEffect(() => {
    if (
      registrationRequest &&
      registrationRequest.registration.registration_status
    ) {
      setRegistration(registrationRequest.registration)
      setComment(registrationRequest.registration.comment)
      setSelectedEvents(registrationRequest.registration.event_ids)
    }
  }, [registrationRequest])
  const { mutate: updateRegistrationMutation } = useMutation({
    mutationFn: updateRegistration,
    onError: (data) => {
      setMessage(
        'Registration update failed with error: ' + data.error,
        'negative'
      )
    },
    onSuccess: (_) => {
      setMessage('Registration update succeeded', 'positive')
    },
  })
  const { mutate: createRegistrationMutation } = useMutation({
    mutationFn: submitEventRegistration,
    onError: (data) => {
      setMessage('Registration failed with error: ' + data.error, 'negative')
    },
    onSuccess: (_) => {
      setMessage('Registration submitted successfully', 'positive')
    },
  })

  return isLoading ? (
    <LoadingMessage />
  ) : (
    <div className={styles.panel}>
      {registration.registration_status ? (
        <>
          <h3>You have registered for {competitionInfo.name}</h3>
          {/* Really weird bug here: Only if I have the console.log statement here (or any other statement referencing it), initialSelected, will work correctly?? */}
          {/* eslint-disable-next-line no-console */}
          {console.log(registration.event_ids)}
          <EventSelector
            handleEventSelection={setSelectedEvents}
            events={competitionInfo.event_ids}
            initialSelected={registration.event_ids}
            size="2x"
          />
        </>
      ) : (
        <>
          <h3> You can register for {competitionInfo.name}</h3>
          <EventSelector
            handleEventSelection={setSelectedEvents}
            events={competitionInfo.event_ids}
            initialSelected={[]}
            size="2x"
          />
        </>
      )}

      <TextArea
        onChange={(_, data) => setComment(data.value)}
        value={comment}
      />
      {registration.registration_status ? (
        <>
          <Button
            color="blue"
            onClick={() => {
              setMessage('Registration is being updated', 'basic')
              updateRegistrationMutation({
                user_id: registration.user_id,
                competition_id: competitionInfo.id,
                comment,
                event_ids: selectedEvents,
              })
            }}
          >
            Update Registration
          </Button>
          <Button
            negative
            onClick={() => {
              setMessage('Registration is being deleted', 'basic')
              updateRegistrationMutation({
                user_id: registration.user_id,
                competition_id: competitionInfo.id,
                comment,
                status: 'deleted',
              })
            }}
          >
            Delete Registration
          </Button>
        </>
      ) : (
        <Button
          onClick={async () => {
            setMessage('Registration is being processed', 'basic')
            createRegistrationMutation({
              user_id: user,
              competition_id: competitionInfo.id,
              event_ids: selectedEvents,
            })
          }}
          positive
        >
          Register
        </Button>
      )}
    </div>
  )
}
