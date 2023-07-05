import { useMutation } from '@tanstack/react-query'
import { UiIcon } from '@thewca/wca-components'
import React, { useContext } from 'react'
import { Button } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { setMessage } from '../../../ui/events/messages'
import styles from './actions.module.scss'

export default function RegistrationActions({ selected, refresh }) {
  const { competitionInfo } = useContext(CompetitionContext)
  const anySelected =
    selected.waiting.length > 0 ||
    selected.accepted.length > 0 ||
    selected.deleted.length > 0
  const anyApprovable =
    selected.waiting.length > 0 || selected.deleted.length > 0
  const anyRejectable =
    selected.accepted.length > 0 || selected.deleted.length > 0
  const anyDeletable =
    selected.waiting.length > 0 || selected.accepted.length > 0
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
          competition_id: competitionInfo.id,
          status,
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
        <Button>
          <UiIcon name="download" /> Export to CSV
        </Button>
        <Button>
          <a
            href={`mailto:?bcc=${[
              ...selected.waiting,
              ...selected.accepted,
              ...selected.deleted,
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
                [...selected.waiting, ...selected.deleted],
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
                [...selected.accepted, ...selected.deleted],
                'waiting'
              )
            }
          >
            <UiIcon name="times" /> Reject
          </Button>
        )}
        {anyDeletable && (
          <Button
            negative
            onClick={() =>
              changeStatus(
                [...selected.waiting, ...selected.accepted],
                'deleted'
              )
            }
          >
            <UiIcon name="trash" /> Delete
          </Button>
        )}
      </Button.Group>
    )
  )
}
