import { useMutation, useQueryClient } from '@tanstack/react-query'
import { EventSelector, UiIcon } from '@thewca/wca-components'
import _ from 'lodash'
import React, { useCallback, useContext, useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
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
import i18n, { TRANSLATIONS_NAMESPACE } from '../../../i18n'
import { getMediumDateString, hasPassed } from '../../../lib/dates'
import { setMessage } from '../../../ui/events/messages'
import Processing from './Processing'

const maxCommentLength = 240

export default function CompetingStep({ nextStep }) {
  const { user, preferredEvents } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const { registration, isRegistered, refetch } =
    useContext(RegistrationContext)

  const { t } = useTranslation(TRANSLATIONS_NAMESPACE, { i18n })

  const [comment, setComment] = useState('')
  const [selectedEvents, setSelectedEvents] = useState(
    preferredEvents.filter((event) =>
      competitionInfo.event_ids.includes(event),
    ),
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
        const { errorCode } = data
        setMessage(
          errorCode
            ? t(`competitions.registration_v2.errors.${errorCode}`)
            : t('registrations.flash.failed') + data.message,
          'negative',
        )
      },
      onSuccess: (data) => {
        setMessage(t('registrations.flash.updated'), 'positive')
        queryClient.setQueryData(
          ['registration', competitionInfo.id, user.id],
          data,
        )
      },
    })

  const { mutate: createRegistrationMutation, isLoading: isCreating } =
    useMutation({
      mutationFn: submitEventRegistration,
      onError: (data) => {
        const { errorCode } = data
        setMessage(
          errorCode
            ? t(`competitions.registration_v2.errors.${errorCode}`)
            : t('competitions.registration_v2.register.error', {
                error: data.message,
              }),
          'negative',
        )
      },
      onSuccess: (_) => {
        // We can't update the registration yet, because there might be more steps needed
        // And the Registration might still be processing
        setMessage(t('registrations.flash.registered'), 'positive')
        setProcessing(true)
      },
    })

  const hasRegistrationEditDeadlinePassed = hasPassed(
    competitionInfo.event_change_deadline_date ?? competitionInfo.start_date,
  )
  const canUpdateRegistration =
    competitionInfo.allow_registration_edits &&
    !hasRegistrationEditDeadlinePassed

  const hasEventsChanged =
    registration?.competing &&
    _.xor(registration.competing.event_ids, selectedEvents).length > 0
  const hasCommentChanged =
    registration?.competing &&
    comment !== (registration.competing.comment ?? '')
  const hasGuestsChanged = registration && guests !== registration.guests

  const hasChanges = hasEventsChanged || hasCommentChanged || hasGuestsChanged

  const commentIsValid =
    comment.trim() || !competitionInfo.force_comment_in_registration
  const maxEvents = competitionInfo.events_per_registration_limit ?? Infinity
  const eventsAreValid =
    selectedEvents.length > 0 && selectedEvents.length <= maxEvents

  const attemptAction = useCallback(
    (action, options = {}) => {
      if (options.checkForChanges && !hasChanges) {
        setMessage(t('competitions.registration_v2.update.noChanges'), 'basic')
      } else if (!commentIsValid) {
        setMessage(
          t('registrations.errors.cannot_register_without_comment'),
          'negative',
        )
      } else if (!eventsAreValid) {
        setMessage(
          maxEvents === Infinity
            ? t('registrations.errors.must_register')
            : t('registrations.errors.exceeds_event_limit.other'),
          'negative',
        )
      } else {
        action()
      }
    },
    [commentIsValid, eventsAreValid, hasChanges, maxEvents, t],
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
        {registration?.competing?.registration_status && (
          <Message info>You have registered for {competitionInfo.name}</Message>
        )}
        {!competitionInfo['registration_opened?'] && (
          <Message warning>
            {t('competitions.registration_v2.register.earlyRegistration')}
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
            <p>{t('registrations.preferred_events_prompt_html')}</p>
          </Form.Field>
          <Form.Field required={competitionInfo.force_comment_in_registration}>
            <label htmlFor="comment">
              {t('competitions.registration_v2.register.comment')}
            </label>
            <TextArea
              maxLength={maxCommentLength}
              onChange={(_, data) => setComment(data.value)}
              value={comment}
              placeholder={
                competitionInfo.force_comment_in_registration
                  ? t('registrations.errors.cannot_register_without_comment')
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
                  (competitionInfo.guests_per_registration_limit ?? 99) + 1, // Arrays start at 0
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

        {isRegistered ? (
          <>
            <Message warning icon>
              <Popup
                trigger={<UiIcon name="circle info" />}
                position="top center"
                content={
                  canUpdateRegistration
                    ? t('competitions.registration_v2.register.until', {
                        date: getMediumDateString(
                          competitionInfo.event_change_deadline_date ??
                            competitionInfo.start_date,
                        ),
                      })
                    : t('competitions.registration_v2.register.passed')
                }
              />
              <Message.Content>
                <Message.Header>
                  {t(
                    'competitions.registration_v2.register.registrationStatus.header',
                  )}
                  {t(
                    `en.competitions.registration_v2.register.registrationStatus.${registration.competing.registration_status}`,
                  )}
                </Message.Header>
                {canUpdateRegistration
                  ? t('registrations.update') // eslint-disable-next-line unicorn/no-nested-ternary
                  : hasRegistrationEditDeadlinePassed
                    ? t('competitions.registration_v2.errors.-4001')
                    : t(
                        'competitions.registration_v2.register.editingDisabled',
                      )}
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
                  {t('registrations.update')}
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
                  {t('registrations.delete_registration')}
                </Button>
              )}
            </ButtonGroup>
          </>
        ) : (
          <>
            <Message info icon floating>
              <Popup
                content={t('registrations.mailer.new.awaits_approval')}
                position="top left"
                trigger={<Icon name="circle info" />}
              />
              <Message.Content>
                {t('competitions.registration_v2.register.disclaimer')}
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
              {t('registrations.register')}
            </Button>
          </>
        )}
      </>
    </Segment>
  )
}
