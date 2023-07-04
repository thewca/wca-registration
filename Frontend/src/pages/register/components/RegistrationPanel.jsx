import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { EventSelector, UiIcon } from '@thewca/wca-components'
import React, { useContext, useEffect, useState } from 'react'
import { Button, Divider, TextArea } from 'semantic-ui-react'
import { AuthContext } from '../../../api/helper/context/auth_context'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './panel.module.scss'

export default function RegistrationPanel() {
  const { user } = useContext(AuthContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const [comment, setComment] = useState('')
  const [selectedEvents, setSelectedEvents] = useState([])
  const [registration, setRegistration] = useState({})
  const queryClient = useQueryClient()
  const { data: registrationRequest, isLoading } = useQuery({
    queryKey: ['registration', user, competitionInfo.id],
    queryFn: () => getSingleRegistration(user, competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })
  useEffect(() => {
    if (registrationRequest?.registration.registration_status) {
      setRegistration(registrationRequest.registration)
      setComment(registrationRequest.registration.comment)
      setSelectedEvents(registrationRequest.registration.event_ids)
    }
  }, [registrationRequest])
  const { mutate: updateRegistrationMutation, isLoading: isUpdating } =
    useMutation({
      mutationFn: updateRegistration,
      onError: (data) => {
        setMessage(
          'Registration update failed with error: ' + data.error,
          'negative'
        )
      },
      onSuccess: (data) => {
        setMessage('Registration update succeeded', 'positive')
        queryClient.setQueryData(
          ['registration', competitionInfo.id, user],
          data
        )
      },
    })
  const { mutate: createRegistrationMutation, isLoading: isCreating } =
    useMutation({
      mutationFn: submitEventRegistration,
      onError: (data) => {
        setMessage('Registration failed with error: ' + data.error, 'negative')
      },
      onSuccess: (_) => {
        // We can't update the registration yet, because there might be more steps needed
        // And the Registration might still be processing
        setMessage('Registration submitted successfully', 'positive')
      },
    })

  return isLoading ? (
    <LoadingMessage />
  ) : (
    <div className={styles.panel}>
      {registration.registration_status ? (
        <>
          <div className={styles.registrationGreeting}>
            You have registered for {competitionInfo.name}
          </div>
          <Divider className={styles.divider} />
          <div className={styles.registrationRow}>
            <div className={styles.eventSelectionText}>
              <div className={styles.eventSelectionHeading}>
                Your Selected Events:
              </div>
              <div className={styles.eventSelectionSubText}>
                You can set your preferred events to prefill future competitions
                in your profile
              </div>
            </div>
            <div className={styles.eventSelectorWrapper}>
              <EventSelector
                handleEventSelection={setSelectedEvents}
                events={competitionInfo.event_ids}
                selected={selectedEvents}
                size="2x"
              />
            </div>
          </div>
        </>
      ) : (
        <>
          <div className={styles.registrationGreeting}>
            You can register for {competitionInfo.name}
          </div>
          <Divider className={styles.divider} />
          <div className={styles.registrationHeading}>
            Registration Fee of $$$ | Waitlist: 0 People
          </div>
          <div className={styles.registrationRow}>
            <div className={styles.eventSelectionText}>
              <div className={styles.eventSelectionHeading}>
                Select Your Events:
              </div>
              <div className={styles.eventSelectionSubText}>
                You can set your preferred events to prefill future competitions
                in your profile
              </div>
            </div>
            <div className={styles.eventSelectorWrapper}>
              <EventSelector
                handleEventSelection={setSelectedEvents}
                events={competitionInfo.event_ids}
                selected={selectedEvents}
                size="2x"
              />
            </div>
          </div>
        </>
      )}
      <div className={styles.registrationRow}>
        <div className={styles.eventSelectionText}>
          <div className={styles.eventSelectionHeading}>
            Additional comments you would like to provide to the organizers:
          </div>
        </div>
        <div className={styles.commentWrapper}>
          <TextArea
            onChange={(_, data) => setComment(data.value)}
            value={comment}
          />
        </div>
      </div>
      <div className={styles.registrationRow}>
        {registration.registration_status ? (
          <div className={styles.registrationButtonWrapper}>
            <div className={styles.registrationWarning}>
              Your Registration Status: {registration.registration_status}
              <UiIcon name="circle info" />
            </div>
            <Button
              disabled={isUpdating}
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
              disabled={isUpdating}
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
          </div>
        ) : (
          <div className={styles.registrationButtonWrapper}>
            <div className={styles.registrationWarning}>
              Submission of Registration does not mean approval to compete.
              <UiIcon name="circle info" />
            </div>
            <Button
              className={styles.registrationButton}
              disabled={isCreating}
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
              Send Registration
            </Button>
          </div>
        )}
      </div>
    </div>
  )
}
