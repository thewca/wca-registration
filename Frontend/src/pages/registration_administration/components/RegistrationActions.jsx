import { UiIcon } from '@thewca/wca-components'
import React, { useState } from 'react'
import { useParams } from 'react-router-dom'
import { Button, Message } from 'semantic-ui-react'
import updateRegistration from '../../../api/registration/patch/update_registration'
import styles from './actions.module.scss'

export default function RegistrationActions({ selected, refresh }) {
  const { competition_id } = useParams()
  const [message, setMessage] = useState({})
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
  const changeStatus = async (attendees, status) => {
    const responses = []
    for (const attendee of attendees) {
      // Should we have a bulk route here? That would make all the changes fail even if there is only one issue
      const response = await updateRegistration(
        attendee,
        competition_id,
        status
      )
      responses.push(response)
    }
    if (responses.some((response) => response.error)) {
      // TODO move this when I make a more general success/error component
      setMessage({
        text: 'Something went wrong when saving registration changes',
        type: 'negative',
      })
    } else {
      setMessage({
        text: 'Successfully saved registration changes',
        type: 'positive',
      })
    }
    refresh()
  }
  return anySelected ? (
    <>
      {message.text ? (
        <Message
          negative={message.type === 'negative'}
          positive={message.type === 'positive'}
          className={styles.message}
        >
          {message.text}
        </Message>
      ) : (
        ''
      )}
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
        {anyApprovable ? (
          <Button
            positive
            onClick={() =>
              changeStatus(
                [
                  ...selected.waiting,
                  ...selected.accepted,
                  ...selected.deleted,
                ],
                'accepted'
              )
            }
          >
            <UiIcon name="check" /> Approve
          </Button>
        ) : (
          ''
        )}
        {anyRejectable ? (
          <Button
            onClick={() =>
              changeStatus(
                [
                  ...selected.waiting,
                  ...selected.accepted,
                  ...selected.deleted,
                ],
                'waiting'
              )
            }
          >
            <UiIcon name="times" /> Reject
          </Button>
        ) : (
          ''
        )}
        {anyDeletable ? (
          <Button
            negative
            onClick={() =>
              changeStatus(
                [
                  ...selected.waiting,
                  ...selected.accepted,
                  ...selected.deleted,
                ],
                'deleted'
              )
            }
          >
            <UiIcon name="trash" /> Delete
          </Button>
        ) : (
          ''
        )}
      </Button.Group>
    </>
  ) : (
    ''
  )
}
