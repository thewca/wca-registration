import { useMutation } from '@tanstack/react-query'
import { UiIcon } from '@thewca/wca-components'
import React, { useContext } from 'react'
import { Button } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { setMessage } from '../../../ui/events/messages'
import styles from './actions.module.scss'

function csvExport(selected) {
  let csvContent = 'data:text/csv;charset=utf-8,'
  csvContent +=
    'user_id,guests,competing.event_ids,competing.registration_status,competing.registered_on,competing.comment,competing.admin_comment\n'
  selected.forEach((registration) => {
    csvContent += `${registration.user_id},
    ${registration.guests},
    ${registration.competing.event_ids.join(';')},
    ${registration.competing.registration_status},
    ${registration.competing.registered_on},
    ${registration.competing.comment},
    ${registration.competing.admin_comment}\n`
  })
  const encodedUri = encodeURI(csvContent)
  window.open(encodedUri)
}

export default function RegistrationActions({ selected, refresh }) {
  const { competitionInfo } = useContext(CompetitionContext)
  const anySelected =
    selected.pending.length > 0 ||
    selected.accepted.length > 0 ||
    selected.cancelled.length > 0 ||
    selected.waiting > 0
  const anyApprovable =
    selected.pending.length > 0 ||
    selected.cancelled.length > 0 ||
    selected.waiting.length > 0
  const anyRejectable =
    selected.accepted.length > 0 ||
    selected.cancelled.length > 0 ||
    selected.waiting.length > 0
  const anyCancellable =
    selected.pending.length > 0 ||
    selected.accepted.length > 0 ||
    selected.waiting.length > 0
  const anyWaitlistable =
    selected.pending.length > 0 ||
    selected.accepted.length > 0 ||
    selected.cancelled.length > 0
  const { mutate: updateRegistrationMutation } = useMutation({
    mutationFn: updateRegistration,
    onError: (data) => {
      setMessage(
        'Registration update failed with error: ' + data.message,
        'negative'
      )
    },
  })
  const changeStatus = async (attendees, status) => {
    attendees.forEach((attendee) => {
      updateRegistrationMutation(
        {
          user_id: attendee,
          competing: {
            status,
          },
          competition_id: competitionInfo.id,
        },
        {
          onSuccess: () => {
            setMessage('Successfully saved registration changes', 'positive')
            refresh()
          },
        }
      )
    })
  }

  return (
    anySelected && (
      <Button.Group className={styles.actions}>
        <Button
          onClick={() => {
            csvExport([
              ...selected.pending,
              ...selected.accepted,
              ...selected.cancelled,
              ...selected.waiting,
            ])
          }}
        >
          <UiIcon name="download" /> Export to CSV
        </Button>
        <Button>
          <a
            href={`mailto:?bcc=${[
              ...selected.pending,
              ...selected.accepted,
              ...selected.cancelled,
              ...selected.waiting,
            ]
              .map((user) => user + '@worldcubeassociation.org')
              .join(',')}`}
            id="email-selected"
            target="_blank"
            className="btn btn-info selected-registrations-actions"
          >
            <UiIcon name="envelope" /> Email
          </a>
        </Button>
        {anyApprovable && (
          <Button
            positive
            onClick={() =>
              changeStatus(
                [
                  ...selected.pending,
                  ...selected.cancelled,
                  ...selected.waiting,
                ],
                'accepted'
              )
            }
          >
            <UiIcon name="check" /> Approve
          </Button>
        )}
        {anyRejectable && (
          <Button
            onClick={() =>
              changeStatus(
                [
                  ...selected.accepted,
                  ...selected.cancelled,
                  ...selected.waiting,
                ],
                'pending'
              )
            }
          >
            <UiIcon name="times" /> Move to Pending
          </Button>
        )}
        {anyWaitlistable && (
          <Button
            color="yellow"
            onClick={() =>
              changeStatus(
                [
                  ...selected.pending,
                  ...selected.cancelled,
                  ...selected.accepted,
                ],
                'waiting_list'
              )
            }
          >
            <UiIcon name="hourglass" /> Move to Waiting List
          </Button>
        )}
        {anyCancellable && (
          <Button
            negative
            onClick={() =>
              changeStatus(
                [
                  ...selected.pending,
                  ...selected.accepted,
                  ...selected.waiting,
                ],
                'cancelled'
              )
            }
          >
            <UiIcon name="trash" /> Cancel Registration
          </Button>
        )}
      </Button.Group>
    )
  )
}
