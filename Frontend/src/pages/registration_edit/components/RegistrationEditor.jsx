import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { EventSelector } from '@thewca/wca-components'
import _ from 'lodash'
import { DateTime } from 'luxon'
import React, { useCallback, useContext, useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useParams } from 'react-router-dom'
import {
  Button,
  Checkbox,
  Header,
  Input,
  Message,
  Segment,
  TextArea,
} from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { getUserInfo } from '../../../api/user/post/get_user_info'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './editor.module.scss'
import Refunds from './Refunds'

export default function RegistrationEditor() {
  const { user_id } = useParams()
  const { competitionInfo } = useContext(CompetitionContext)
  const { t } = useTranslation()

  const [comment, setComment] = useState('')
  const [adminComment, setAdminComment] = useState('')
  const [status, setStatus] = useState('')
  const [waitingListPosition, setWaitingListPosition] = useState(0)
  const [guests, setGuests] = useState(0)
  const [selectedEvents, setSelectedEvents] = useState([])
  const [registration, setRegistration] = useState({})
  const [isCheckingRefunds, setIsCheckingRefunds] = useState(false)

  const queryClient = useQueryClient()

  const { data: serverRegistration } = useQuery({
    queryKey: ['registration', competitionInfo.id, user_id],
    queryFn: () =>
      getSingleRegistration(Number.parseInt(user_id, 10), competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })

  const { isLoading, data: competitorInfo } = useQuery({
    queryKey: ['info', user_id],
    queryFn: () => getUserInfo(user_id),
  })

  const { mutate: updateRegistrationMutation, isLoading: isUpdating } =
    useMutation({
      mutationFn: updateRegistration,
      onError: (data) => {
        const { errorCode } = data
        setMessage(
          errorCode
            ? t(`errors.${errorCode}`)
            : 'Registration update failed with error: ' + data.message,
          'negative',
        )
      },
      onSuccess: (data) => {
        setMessage('Registration update succeeded', 'positive')
        queryClient.setQueryData(
          ['registration', competitionInfo.id, user_id],
          data,
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
        serverRegistration.registration.competing.admin_comment ?? '',
      )
      setWaitingListPosition(
        serverRegistration.registration.competing.waiting_list_position ?? 0,
      )
      setGuests(serverRegistration.registration.guests ?? 0)
    }
  }, [serverRegistration])

  const hasEventsChanged =
    serverRegistration &&
    _.xor(serverRegistration.registration.competing.event_ids, selectedEvents)
      .length > 0
  const hasCommentChanged =
    serverRegistration &&
    comment !== (serverRegistration.registration.competing.comment ?? '')
  const hasAdminCommentChanged =
    serverRegistration &&
    adminComment !==
      (serverRegistration.registration.competing.admin_comment ?? '')
  const hasStatusChanged =
    serverRegistration &&
    status !== serverRegistration.registration.competing.registration_status
  const hasGuestsChanged = false

  const hasChanges =
    hasEventsChanged ||
    hasCommentChanged ||
    hasAdminCommentChanged ||
    hasStatusChanged ||
    hasGuestsChanged

  const commentIsValid =
    comment || !competitionInfo.force_comment_in_registration
  const maxEvents = competitionInfo.events_per_registration_limit ?? Infinity
  const eventsAreValid =
    selectedEvents.length > 0 && selectedEvents.length <= maxEvents

  const handleRegisterClick = useCallback(() => {
    if (!hasChanges) {
      setMessage('There are no changes', 'basic')
    } else if (!commentIsValid) {
      setMessage('You must include a comment', 'negative')
    } else if (!eventsAreValid) {
      setMessage(
        maxEvents === Infinity
          ? 'You must select at least 1 event'
          : `You must select between 1 and ${maxEvents} events`,
        'negative',
      )
    } else {
      setMessage('Updating Registration', 'basic')
      updateRegistrationMutation({
        user_id,
        competing: {
          status,
          event_ids: selectedEvents,
          comment,
          admin_comment: adminComment,
          waiting_list_position: waitingListPosition,
        },
        competition_id: competitionInfo.id,
      })
    }
  }, [
    hasChanges,
    commentIsValid,
    eventsAreValid,
    maxEvents,
    updateRegistrationMutation,
    user_id,
    status,
    selectedEvents,
    comment,
    adminComment,
    waitingListPosition,
    competitionInfo.id,
  ])

  const registrationEditDeadlinePassed =
    DateTime.fromISO(
      competitionInfo.event_change_deadline_date ?? new Date().toISOString(),
    ) < DateTime.fromJSDate(new Date())

  return (
    <Segment padded attached>
      {!registration?.competing?.registration_status || isLoading ? (
        <LoadingMessage />
      ) : (
        <div>
          <Header>{competitorInfo.user.name}</Header>
          <EventSelector
            handleEventSelection={setSelectedEvents}
            selected={selectedEvents}
            disabled={registrationEditDeadlinePassed}
            events={competitionInfo.event_ids}
            size="2x"
          />

          <Header>Comment</Header>
          <TextArea
            id="competitor-comment"
            maxLength={240}
            value={comment}
            disabled={registrationEditDeadlinePassed}
            onChange={(_, data) => {
              setComment(data.value)
            }}
          />

          <Header>Administrative Notes</Header>
          <TextArea
            id="admin-comment"
            maxLength={240}
            value={adminComment}
            disabled={registrationEditDeadlinePassed}
            onChange={(_, data) => {
              setAdminComment(data.value)
            }}
          />

          <Header>Status</Header>
          <div className={styles.registrationStatus}>
            <Checkbox
              radio
              label="Pending"
              name="checkboxRadioGroup"
              value="pending"
              checked={status === 'pending'}
              disabled={registrationEditDeadlinePassed}
              onChange={(_, data) => setStatus(data.value)}
            />
            <br />
            <Checkbox
              radio
              label="Accepted"
              name="checkboxRadioGroup"
              value="accepted"
              checked={status === 'accepted'}
              disabled={registrationEditDeadlinePassed}
              onChange={(_, data) => setStatus(data.value)}
            />
            <br />
            <Checkbox
              radio
              label="Waiting List"
              name="checkboxRadioGroup"
              value="waiting_list"
              checked={status === 'waiting_list'}
              disabled={registrationEditDeadlinePassed}
              onChange={(_, data) => setStatus(data.value)}
            />
            <br />
            <Checkbox
              radio
              label="Cancelled"
              name="checkboxRadioGroup"
              value="cancelled"
              disabled={registrationEditDeadlinePassed}
              checked={status === 'cancelled'}
              onChange={(_, data) => setStatus(data.value)}
            />
            <br />
            <Header>Guests</Header>
            <Input
              disabled={registrationEditDeadlinePassed}
              type="number"
              min={0}
              max={99}
              value={guests}
              onChange={(_, data) => setGuests(data.value)}
            />
          </div>

          {registrationEditDeadlinePassed ? (
            <Message negative>Registration edit deadline has passed.</Message>
          ) : (
            <Button
              color="blue"
              onClick={handleRegisterClick}
              disabled={isUpdating}
            >
              Update Registration
            </Button>
          )}

          {competitionInfo['using_stripe_payments?'] && (
            <>
              <Header>
                Payment status: {registration.payment.payment_status}
              </Header>
              {registration.payment.payment_status === 'succeeded' && (
                <Button onClick={() => setIsCheckingRefunds(true)}>
                  Show Available Refunds
                </Button>
              )}
              <Refunds
                competitionId={competitionInfo.id}
                userId={user_id}
                open={isCheckingRefunds}
                onExit={() => setIsCheckingRefunds(false)}
              />
            </>
          )}
        </div>
      )}
    </Segment>
  )
}
