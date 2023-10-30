import * as currencies from '@dinero.js/currencies'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { EventSelector, UiIcon } from '@thewca/wca-components'
import { dinero, toDecimal } from 'dinero.js'
import React, { useContext, useEffect, useState } from 'react'
import { Button, Divider, Dropdown, Popup, TextArea } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { UserContext } from '../../../api/helper/context/user_context'
import { getSingleRegistration } from '../../../api/registration/get/get_registrations'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import submitEventRegistration from '../../../api/registration/post/submit_registration'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'
import styles from './panel.module.scss'
import Processing from './Processing'

export default function CompetingStep({ nextStep }) {
  const { user } = useContext(UserContext)
  const { competitionInfo } = useContext(CompetitionContext)
  const [comment, setComment] = useState('')
  const [selectedEvents, setSelectedEvents] = useState([])
  const [guests, setGuests] = useState(0)
  const [registration, setRegistration] = useState({})
  const [processing, setProcessing] = useState(false)
  const queryClient = useQueryClient()
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
      setGuests(registrationRequest.registration.guests)
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

  return isLoading ? (
    <LoadingMessage />
  ) : (
    <div>
      {processing && (
        <div className={styles.processing}>
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
        </div>
      )}
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
                  You can set your preferred events to prefill future
                  competitions in your profile
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
              Registration Fee of{' '}
              {toDecimal(
                dinero({
                  amount: competitionInfo.base_entry_fee_lowest_denomination,
                  currency: currencies[competitionInfo.currency_code],
                }),
                ({ value, currency }) => `${currency.code} ${value}`
              ) ?? 'No Entry Fee'}{' '}
              | Waitlist: 0 People
            </div>
            <div className={styles.registrationRow}>
              <div className={styles.eventSelectionText}>
                <div className={styles.eventSelectionHeading}>
                  Select Your Events:
                </div>
                <div className={styles.eventSelectionSubText}>
                  You can set your preferred events to prefill future
                  competitions in your profile
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
              maxLength={180}
              onChange={(_, data) => setComment(data.value)}
              value={comment}
            />
            <div className={styles.commentCounter}>{comment.length}/180</div>
          </div>
        </div>
        <div className={styles.registrationRow}>
          <div className={styles.eventSelectionText}>
            <div className={styles.eventSelectionHeading}>Guests</div>
          </div>
          <div className={styles.commentWrapper}>
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
          </div>
        </div>
        <div className={styles.registrationRow}>
          {registration?.competing?.registration_status ? (
            <div className={styles.registrationButtonWrapper}>
              <div className={styles.registrationWarning}>
                Your Registration Status:
                {registration.competing.registration_status}
                <br />
                {competitionInfo.allow_registration_edits
                  ? 'Update Your Registration below'
                  : 'Registration Editing is disabled'}
                <UiIcon name="circle info" />
              </div>
              <Button
                disabled={
                  isUpdating ||
                  !competitionInfo.allow_registration_edits ||
                  (competitionInfo.force_comment_in_registration &&
                    comment === '')
                }
                color="blue"
                onClick={() => {
                  setMessage('Registration is being updated', 'basic')
                  updateRegistrationMutation({
                    user_id: registration.user_id,
                    competition_id: competitionInfo.id,
                    competing: {
                      comment,
                      guests,
                      event_ids: selectedEvents,
                    },
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
                    competing: {
                      status: 'cancelled',
                    },
                  })
                }}
              >
                Delete Registration
              </Button>
            </div>
          ) : (
            <div className={styles.registrationButtonWrapper}>
              <div className={styles.registrationWarning}>
                <Popup
                  content="You will only be accepted if you have met all reigstration requirements"
                  position="top center"
                  trigger={
                    <span>
                      Submission of Registration does not mean approval to
                      compete <UiIcon name="circle info" />
                    </span>
                  }
                />
              </div>
              <Button
                className={styles.registrationButton}
                disabled={isCreating || selectedEvents.length === 0}
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
                positive
              >
                Send Registration
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
