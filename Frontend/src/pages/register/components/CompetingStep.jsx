import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { EventSelector, UiIcon } from '@thewca/wca-components'
import moment from 'moment'
import React, { useContext, useEffect, useState } from 'react'
import {
  Button,
  ButtonGroup,
  Divider,
  Dropdown,
  Form,
  Icon,
  Message,
  Popup,
  Segment,
  TextArea,
} from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { UserContext } from '../../../api/helper/context/user_context'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import Processing from './Processing'

export default function CompetingStep({ nextStep }) {
  const { user } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)

  const queryClient = useQueryClient()

  const [comment, setComment] = useState('')
  const [selectedEvents, setSelectedEvents] = useState([])
  const [guests, setGuests] = useState(0)

  const [registration, setRegistration] = useState({})
  const [processing, setProcessing] = useState(false)

  const {
    data: registrationRequest,
    isLoading,
    refetch,
  } = useQuery({
    queryKey: ['registration', competitionInfo.id, user.id],
    queryFn: () => getSingleRegistration(user.id, competitionInfo.id),
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    refetchOnMount: 'always',
    retry: false,
    onError: (err) => {
      setMessage(err.error, 'error')
    },
  })

  useEffect(() => {
    if (registrationRequest?.registration?.competing) {
      setRegistration(registrationRequest.registration)
      setComment(registrationRequest.registration.competing.comment ?? '')
      setSelectedEvents(registrationRequest.registration.competing.event_ids)
      // Ruby sends this as "1.0"
      setGuests(Number(registrationRequest.registration.guests))
    }
  }, [registrationRequest])

  const { mutate: updateRegistrationMutation, isLoading: isUpdating } =
    useMutation({
      mutationFn: updateRegistration,
      onError: (data) => {
        setMessage(
          'Registration update failed with error: ' + data.message,
          'negative'
        )
      },
      onSuccess: (data) => {
        setMessage('Registration update succeeded', 'positive')
        queryClient.setQueryData(
          ['registration', competitionInfo.id, user.id],
          data
        )
      },
    })

  const { mutate: createRegistrationMutation, isLoading: isCreating } =
    useMutation({
      mutationFn: submitEventRegistration,
      onError: (data) => {
        setMessage(
          'Registration failed with error: ' + data.message,
          'negative'
        )
      },
      onSuccess: (_) => {
        // We can't update the registration yet, because there might be more steps needed
        // And the Registration might still be processing
        setMessage('Registration submitted successfully', 'positive')
        setProcessing(true)
      },
    })

  const canUpdateRegistration =
    competitionInfo.allow_registration_edits &&
    new Date(competitionInfo.event_change_deadline_date) > Date.now()

  return isLoading ? (
    <LoadingMessage />
  ) : (
    <Segment basic>
      {processing && (
        <Processing
          onProcessingComplete={() => {
            setProcessing(false)

            if (competitionInfo['using_stripe_payments?']) {
              nextStep()
            } else {
              refetch()
            }
          }}
        />
      )}
      <>
        {registration.registration_status && (
          <Message info>You have registered for {competitionInfo.name}</Message>
        )}
        {!competitionInfo['registration_opened?'] && (
          <Message warning>
            Registration is not open yet, but you can still register as a
            competition organizer or delegate.
          </Message>
        )}
        <Form>
          <Form.Field>
            <label>Events</label>
            <EventSelector
              handleEventSelection={setSelectedEvents}
              events={competitionInfo.event_ids}
              selected={selectedEvents}
              size="2x"
            />
            <p>
              You can set your preferred events to prefill future competitions
              in your profile
            </p>
          </Form.Field>
          <Form.Field required={competitionInfo.force_comment_in_registration}>
            <label>Additional comments to the organizers</label>
            <TextArea
              maxLength={240}
              onChange={(_, data) => setComment(data.value)}
              value={comment}
              placeholder={
                competitionInfo.force_comment_in_registration
                  ? 'A comment is required. Read the Registration Requirements to find out why.'
                  : ''
              }
              id="comment"
            />
            <p>{comment.length}/240</p>
          </Form.Field>
          <Form.Field>
            <label>Guests</label>
            <Dropdown
              value={guests}
              onChange={(e, data) => setGuests(data.value)}
              selection
              options={[
                ...new Array(
                  (competitionInfo.guests_per_registration_limit ?? 99) + 1 // Arrays start at 0
                ),
              ].map((_, index) => {
                return {
                  key: `registration-guest-dropdown-${index}`,
                  text: index,
                  value: index,
                }
              })}
            />
          </Form.Field>
        </Form>
        <Divider />
        {registration?.competing?.registration_status ? (
          <>
            <Message warning icon>
              <Popup
                trigger={<UiIcon name="circle info" />}
                position="top center"
                content={
                  canUpdateRegistration
                    ? `You can update your registration until ${moment(
                        competitionInfo.event_change_deadline_date ??
                          competitionInfo.end_date
                      ).format('ll')}`
                    : 'You can no longer update your registration'
                }
              />
              <Message.Content>
                <Message.Header>Your Registration Status</Message.Header>
                {canUpdateRegistration
                  ? 'Update Your Registration below'
                  : 'Registration Editing is disabled'}
              </Message.Content>
            </Message>
            <ButtonGroup>
              {moment(
                // If no deadline is set default to always be in the future
                competitionInfo.event_change_deadline_date ?? Date.now() + 1
              ).isAfter() &&
                registration.competing.registration_status !== 'cancelled' && (
                  <Button
                    primary
                    disabled={
                      isUpdating ||
                      !competitionInfo.allow_registration_edits ||
                      (competitionInfo.force_comment_in_registration &&
                        comment.trim() === '')
                    }
                    onClick={() => {
                      setMessage('Registration is being updated', 'basic')
                      updateRegistrationMutation({
                        user_id: registration.user_id,
                        competition_id: competitionInfo.id,
                        competing: {
                          comment,
                          event_ids: selectedEvents,
                        },
                        guests,
                      })
                    }}
                  >
                    Update Registration
                  </Button>
                )}
              {registration.competing.registration_status === 'cancelled' && (
                <Button
                  secondary
                  disabled={
                    isUpdating ||
                    (competitionInfo.force_comment_in_registration &&
                      comment.trim() === '')
                  }
                  onClick={() => {
                    setMessage('Registration is being updated', 'basic')
                    updateRegistrationMutation({
                      user_id: registration.user_id,
                      competition_id: competitionInfo.id,
                      competing: {
                        comment,
                        guests,
                        event_ids: selectedEvents,
                        status: 'pending',
                      },
                    })
                  }}
                >
                  Re-Register
                </Button>
              )}
              {competitionInfo.allow_registration_self_delete_after_acceptance &&
                competitionInfo['registration_opened?'] &&
                registration.competing.registration_status !== 'cancelled' && (
                  <Button
                    disabled={isUpdating}
                    negative
                    onClick={() => {
                      setMessage('Registration is being deleted', 'basic')
                      updateRegistrationMutation({
                        user_id: registration.user_id,
                        competition_id: competitionInfo.id,
                        competing: {
                          status: 'cancelled',
                        },
                      })
                    }}
                  >
                    Delete Registration
                  </Button>
                )}
            </ButtonGroup>
          </>
        ) : (
          <>
            <Message info icon floating>
              <Popup
                content="You will only be accepted if you have met all reigstration requirements"
                position="top left"
                trigger={<Icon name="circle info" />}
              />
              <Message.Content>
                Submission of Registration does not mean approval to compete
              </Message.Content>
            </Message>

            <Button
              positive
              fluid
              icon
              labelPosition="left"
              disabled={
                isCreating ||
                selectedEvents.length === 0 ||
                (competitionInfo.force_comment_in_registration &&
                  comment.trim() === '')
              }
              onClick={async () => {
                setMessage('Registration is being processed', 'basic')
                createRegistrationMutation({
                  user_id: user.id.toString(),
                  competition_id: competitionInfo.id,
                  competing: {
                    event_ids: selectedEvents,
                    comment,
                    guests,
                  },
                })
              }}
            >
              <Icon name="paper plane" />
              Send Registration
            </Button>
          </>
        )}
      </>
    </Segment>
  )
}
