import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { EventSelector } from '@thewca/wca-components'
import React, { useContext, useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { Button, Checkbox, TextArea } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import getCompetitorInfo from '../../../api/user/get/get_user_info'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './editor.module.scss'

export default function RegistrationEditor() {
  const { user_id } = useParams()
  const { competitionInfo } = useContext(CompetitionContext)
  const [comment, setComment] = useState('')
  const [adminComment, setAdminComment] = useState('')
  const [status, setStatus] = useState('')
  const [selectedEvents, setSelectedEvents] = useState([])
  const [registration, setRegistration] = useState({})
  const queryClient = useQueryClient()
  const { data: serverRegistration } = useQuery({
    queryKey: ['registration', competitionInfo.id, user_id],
    queryFn: () => getSingleRegistration(user_id, competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })
  const { isLoading, data: competitorInfo } = useQuery({
    queryKey: ['info', user_id],
    queryFn: () => getCompetitorInfo(user_id),
  })
  const { mutate: updateRegistrationMutation } = useMutation({
    mutationFn: updateRegistration,
    onError: (data) => {
      setMessage(
        'Registration update failed with error: ' + data.errorCode,
        'negative'
      )
    },
    onSuccess: (data) => {
      setMessage('Registration update succeeded', 'positive')
      queryClient.setQueryData(
        ['registration', competitionInfo.id, user_id],
        data
      )
    },
  })
  useEffect(() => {
    if (serverRegistration) {
      setRegistration(serverRegistration.registration)
      setComment(serverRegistration.registration.competing.comment ?? '')
      setStatus(serverRegistration.registration.competing.registration_status)
      setSelectedEvents(serverRegistration.registration.competing.event_ids)
      setAdminComment(
        serverRegistration.registration.competing.admin_comment ?? ''
      )
    }
  }, [serverRegistration])

  return (
    <div className={styles.editor}>
      {!registration?.competing?.registration_status || isLoading ? (
        <LoadingMessage />
      ) : (
        <div>
          <h2>{competitorInfo.user.name}</h2>
          <EventSelector
            handleEventSelection={setSelectedEvents}
            selected={selectedEvents}
            events={competitionInfo.event_ids}
            size="2x"
          />
          <h3> Comment </h3>
          <div className={styles.commentWrapper}>
            <TextArea
              maxLength={180}
              value={comment}
              onChange={(_, data) => {
                setComment(data.value)
              }}
            />
          </div>
          <h3> Administrative Notes </h3>
          <div className={styles.commentWrapper}>
            <TextArea
              maxLength={180}
              value={adminComment}
              onChange={(_, data) => {
                setAdminComment(data.value)
              }}
            />
          </div>
          <h3> Status </h3>
          <div className={styles.registrationStatus}>
            <Checkbox
              radio
              label="Pending"
              name="checkboxRadioGroup"
              value="pending"
              checked={status === 'pending'}
              onChange={(_, data) => setStatus(data.value)}
            />
            <br />
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
              label="Waiting List"
              name="checkboxRadioGroup"
              value="waiting_list"
              checked={status === 'waiting_list'}
              onChange={(_, data) => setStatus(data.value)}
            />
            <br />
            <Checkbox
              radio
              label="Cancelled"
              name="checkboxRadioGroup"
              value="cancelled"
              checked={status === 'cancelled'}
              onChange={(_, data) => setStatus(data.value)}
            />
          </div>
          <Button
            color="blue"
            onClick={() => {
              setMessage('Updating Registration', 'basic')
              updateRegistrationMutation({
                user_id,
                competing: {
                  status,
                  event_id: selectedEvents,
                  comment,
                  admin_comment: adminComment,
                },
                competition_id: competitionInfo.id,
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
