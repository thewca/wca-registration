import { useMutation, useQueryClient } from '@tanstack/react-query'
import { EventSelector, UiIcon } from '@thewca/wca-components'
import _ from 'lodash'
import moment from 'moment'
import React, { useCallback, useContext, useEffect, useState } from 'react'
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
import { RegistrationContext } from '../../../api/helper/context/registration_context'
import { UserContext } from '../../../api/helper/context/user_context'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import { setMessage } from '../../../ui/events/messages'
import Processing from './Processing'

const maxCommentLength = 240

export default function CompetingStep({ nextStep }) {
  const { user, preferredEvents } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const { registration, isRegistered, refetch } =
    useContext(RegistrationContext)

  const [comment, setComment] = useState('')
  const [selectedEvents, setSelectedEvents] = useState(
    preferredEvents.filter((event) => competitionInfo.event_ids.includes(event))
  )
  const [guests, setGuests] = useState(0)

  const [processing, setProcessing] = useState(false)

  useEffect(() => {
    if (isRegistered) {
      setComment(registration.competing.comment ?? '')
      setSelectedEvents(registration.competing.event_ids)
      setGuests(registration.guests)
    }
  }, [isRegistered, registration])

  const queryClient = useQueryClient()
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

  const hasRegistrationEditDeadlinePassed =
    new Date(
      competitionInfo.event_change_deadline_date ?? competitionInfo.start_date
    ) < Date.now()
  const canUpdateRegistration =
    competitionInfo.allow_registration_edits &&
    !hasRegistrationEditDeadlinePassed

  const hasEventsChanged =
    registration?.competing &&
    _.xor(registration.competing.event_ids, selectedEvents).length > 0
  const hasCommentChanged =
    registration?.competing &&
    comment !== (registration.competing.comment ?? '')
  const hasGuestsChanged =
    registration && guests !== Number.parseInt(registration.guests, 10)

  const hasChanges = hasEventsChanged || hasCommentChanged || hasGuestsChanged

  const commentIsValid =
    comment.trim() || !competitionInfo.force_comment_in_registration
  // TODO: get max events can register for
  const maxEvents = competitionInfo.events_per_registration_limit
  const eventsAreValid =
    selectedEvents.length > 0 && selectedEvents.length <= maxEvents

  const attemptAction = useCallback(
    (action, options = {}) => {
      if (options.checkForChanges && !hasChanges) {
        setMessage('There are no changes', 'basic')
      } else if (!commentIsValid) {
        setMessage('You must include a comment', 'negative')
      } else if (!eventsAreValid) {
        setMessage(
          maxEvents === Infinity
            ? 'You must select at least 1 event'
            : `You must select between 1 and ${maxEvents} events`,
          'negative'
        )
      } else {
        action()
      }
    },
    [commentIsValid, eventsAreValid, hasChanges, maxEvents]
  )

  const actionCreateRegistration = () => {
    setMessage('Registration is being processed', 'basic')
    createRegistrationMutation({
      user_id: user.id.toString(),
      competition_id: competitionInfo.id,
      competing: {
        event_ids: selectedEvents,
        comment,
      },
      guests,
    })
  }

  const actionUpdateRegistration = () => {
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
  }

  const actionReRegister = () => {
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
  }

  const actionDeleteRegistration = () => {
    setMessage('Registration is being deleted', 'basic')
    updateRegistrationMutation({
      user_id: registration.user_id,
      competition_id: competitionInfo.id,
      competing: {
        status: 'cancelled',
      },
    })
  }

  const shouldShowUpdateButton =
    isRegistered &&
    !hasRegistrationEditDeadlinePassed &&
    registration.competing.registration_status !== 'cancelled'

  const shouldShowReRegisterButton =
    registration?.competing?.registration_status === 'cancelled'

  const shouldShowDeleteButton =
    isRegistered &&
    registration.competing.registration_status !== 'cancelled' &&
    (registration.competing.registration_status !== 'accepted' ||
      competitionInfo.allow_registration_self_delete_after_acceptance) &&
    competitionInfo['registration_opened?']

  return (
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
        {registration?.registration_status && (
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
            <label htmlFor="event-selection">Events</label>
            <EventSelector
              handleEventSelection={setSelectedEvents}
              events={competitionInfo.event_ids}
              selected={selectedEvents}
              size="2x"
              id="event-selection"
            />
            <p>
              You can set your preferred events to prefill future competitions
              in your profile
            </p>
          </Form.Field>
          <Form.Field required={competitionInfo.force_comment_in_registration}>
            <label htmlFor="comment">
              Additional comments to the organizers
            </label>
            <TextArea
              maxLength={maxCommentLength}
              onChange={(_, data) => setComment(data.value)}
              value={comment}
              placeholder={
                competitionInfo.force_comment_in_registration
                  ? 'A comment is required. Read the Registration Requirements to find out why.'
                  : ''
              }
              id="comment"
            />
            <p>
              {comment.length}/{maxCommentLength}
            </p>
          </Form.Field>
          <Form.Field>
            <label htmlFor="guest-dropdown">Guests</label>
            <Dropdown
              id="guest-dropdown"
              value={guests}
              onChange={(_, data) => setGuests(data.value)}
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
                          competitionInfo.start_date
                      ).format('ll')}`
                    : 'You can no longer update your registration'
                }
              />
              <Message.Content>
                <Message.Header>
                  Your Registration Status:{' '}
                  {registration.competing.registration_status}
                </Message.Header>
                {canUpdateRegistration
                  ? 'Update your registration below' // eslint-disable-next-line unicorn/no-nested-ternary
                  : hasRegistrationEditDeadlinePassed
                  ? 'The deadline to edit your registration has passed'
                  : 'Registration editing is disabled for this competition'}
              </Message.Content>
            </Message>

            <ButtonGroup>
              {shouldShowUpdateButton && (
                <Button
                  primary
                  disabled={isUpdating || !canUpdateRegistration}
                  onClick={() =>
                    attemptAction(actionUpdateRegistration, {
                      checkForChanges: true,
                    })
                  }
                >
                  Update Registration
                </Button>
              )}

              {shouldShowReRegisterButton && (
                <Button
                  secondary
                  disabled={isUpdating}
                  onClick={() => attemptAction(actionReRegister)}
                >
                  Re-Register
                </Button>
              )}

              {shouldShowDeleteButton && (
                <Button
                  disabled={isUpdating}
                  negative
                  onClick={actionDeleteRegistration}
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
                content="You will only be accepted if you have met all registration requirements"
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
              disabled={isCreating}
              onClick={() => attemptAction(actionCreateRegistration)}
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
