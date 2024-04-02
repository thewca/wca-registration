import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { EventSelector } from '@thewca/wca-components'
import _ from 'lodash'
import React, {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import { useParams } from 'react-router-dom'
import {
  Accordion,
  Button,
  Checkbox,
  Header,
  Input,
  Message,
  Popup,
  Segment,
  Table,
  TextArea,
} from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { getUsersInfo } from '../../../api/user/post/get_user_info'
import {
  getShortDateString,
  getShortTimeString,
  hasPassed,
} from '../../../lib/dates'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './editor.module.scss'
import Refunds from './Refunds'

export default function RegistrationEditor() {
  const userId = Number.parseInt(useParams().user_id, 10)
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
  const [isHistoryCollapsed, setIsHistoryCollapsed] = useState(true)

  const queryClient = useQueryClient()

  const { data: serverRegistration } = useQuery({
    queryKey: ['registration-admin', competitionInfo.id, userId],
    queryFn: () => getSingleRegistration(userId, competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
  })

  const { isLoading, data: competitorsInfo } = useQuery({
    queryKey: ['info', userId],
    queryFn: () =>
      getUsersInfo([
        ...new Set([
          userId,
          ...serverRegistration.history.map((e) => e.acting_user_id),
        ]),
      ]),
    enabled: Boolean(serverRegistration),
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
          ['registration', competitionInfo.id, userId],
          data,
        )
      },
    })

  useEffect(() => {
    if (serverRegistration) {
      setRegistration(serverRegistration)
      setComment(serverRegistration.competing.comment ?? '')
      setStatus(serverRegistration.competing.registration_status)
      setSelectedEvents(serverRegistration.competing.event_ids)
      setAdminComment(serverRegistration.competing.admin_comment ?? '')
      setWaitingListPosition(
        serverRegistration.competing.waiting_list_position ?? 0,
      )
      setGuests(serverRegistration.guests ?? 0)
    }
  }, [serverRegistration])

  const hasEventsChanged =
    serverRegistration &&
    _.xor(serverRegistration.competing.event_ids, selectedEvents).length > 0
  const hasCommentChanged =
    serverRegistration &&
    comment !== (serverRegistration.competing.comment ?? '')
  const hasAdminCommentChanged =
    serverRegistration &&
    adminComment !== (serverRegistration.competing.admin_comment ?? '')
  const hasStatusChanged =
    serverRegistration &&
    status !== serverRegistration.competing.registration_status
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
        user_id: userId,
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
    userId,
    status,
    selectedEvents,
    comment,
    adminComment,
    waitingListPosition,
    competitionInfo.id,
  ])

  const registrationEditDeadlinePassed =
    Boolean(competitionInfo.event_change_deadline_date) &&
    hasPassed(competitionInfo.event_change_deadline_date)

  const competitorInfo = useMemo(() => {
    if (competitorsInfo) {
      return competitorsInfo.find((c) => c.id === userId)
    }
  }, [competitorsInfo, userId])

  return (
    <Segment padded attached>
      {!registration?.competing?.registration_status || isLoading ? (
        <LoadingMessage />
      ) : (
        <div>
          {competitorInfo.wca_id && (
            <Message>
              This person registered with an account. You can edit their
              personal information{' '}
              <a href={`${process.env.WCA_URL}/users/${userId}/edit`}>here.</a>
            </Message>
          )}
          <Header>{competitorInfo.name}</Header>
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
                userId={userId}
                open={isCheckingRefunds}
                onExit={() => setIsCheckingRefunds(false)}
              />
            </>
          )}
          <Accordion>
            <Accordion.Title
              active={isHistoryCollapsed}
              onClick={() => setIsHistoryCollapsed(!isHistoryCollapsed)}
            >
              Registration History
            </Accordion.Title>
            <Accordion.Content>
              <Table>
                <Table.Header>
                  <Table.Row>
                    <Table.HeaderCell>Timestamp</Table.HeaderCell>
                    <Table.HeaderCell>Changes</Table.HeaderCell>
                    <Table.HeaderCell>Acting User</Table.HeaderCell>
                    <Table.HeaderCell>Action</Table.HeaderCell>
                  </Table.Row>
                </Table.Header>
                <Table.Body>
                  {registration.history.map((entry) => (
                    <Table.Row key={entry.timestamp}>
                      <Table.Cell>
                        <Popup
                          content={getShortTimeString(entry.timestamp)}
                          trigger={
                            <span>{getShortDateString(entry.timestamp)}</span>
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>
                        {!_.isEmpty(entry.changed_attributes) ? (
                          Object.entries(entry.changed_attributes).map(
                            ([k, v]) => (
                              <span key={k}>
                                Changed {k} to {JSON.stringify(v)} <br />
                              </span>
                            ),
                          )
                        ) : (
                          <span>Registration Created</span>
                        )}
                      </Table.Cell>
                      <Table.Cell>
                        {
                          competitorsInfo.find(
                            (c) => c.id === entry.actor_user_id,
                          ).name
                        }
                      </Table.Cell>
                      <Table.Cell>{entry.action}</Table.Cell>
                    </Table.Row>
                  ))}
                </Table.Body>
              </Table>
            </Accordion.Content>
          </Accordion>
        </div>
      )}
    </Segment>
  )
}
