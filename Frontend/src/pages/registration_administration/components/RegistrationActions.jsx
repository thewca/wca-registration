import { useMutation } from '@tanstack/react-query'
import { UiIcon } from '@thewca/wca-components'
import React, { useContext } from 'react'
import { useTranslation } from 'react-i18next'
import { Button } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { PermissionsContext } from '../../../api/helper/context/permission_context'
import { updateRegistration } from '../../../api/registration/patch/update_registration'
import { setMessage } from '../../../ui/events/messages'
import styles from './actions.module.scss'
import i18n, { TRANSLATIONS_NAMESPACE } from '../../../i18n'

function csvExport(selected, registrations) {
  let csvContent = 'data:text/csv;charset=utf-8,'
  csvContent +=
    'user_id,guests,competing.event_ids,competing.registration_status,competing.registered_on,competing.comment,competing.admin_comment\n'
  registrations
    .filter((r) => selected.includes(r.user.id))
    .forEach((registration) => {
      csvContent += `${registration.user_id},${
        registration.guests
      },${registration.competing.event_ids.join(';')},${
        registration.competing.registration_status
      },${registration.competing.registered_on},${
        registration.competing.comment
      },${registration.competing.admin_comment}\n`
    })
  const encodedUri = encodeURI(csvContent)
  window.open(encodedUri)
}

export default function RegistrationActions({
  partitionedSelected,
  userEmailMap,
  refresh,
  registrations,
  spotsRemaining,
}) {
  const { competitionInfo } = useContext(CompetitionContext)
  const { isOrganizerOrDelegate } = useContext(PermissionsContext)

  const { t } = useTranslation(TRANSLATIONS_NAMESPACE, { i18n })

  const selectedCount = Object.values(partitionedSelected).reduce(
    (sum, part) => sum + part.length,
    0,
  )
  const anySelected = selectedCount > 0

  const { pending, accepted, cancelled, waiting } = partitionedSelected
  const anyRejectable = pending.length < selectedCount
  const anyApprovable = accepted.length < selectedCount
  const anyCancellable = cancelled.length < selectedCount
  const anyWaitlistable = waiting.length < selectedCount

  const selectedEmails = [...pending, ...accepted, ...cancelled, ...waiting]
    .map((userId) => userEmailMap[userId])
    .join(',')

  const { mutate: updateRegistrationMutation } = useMutation({
    mutationFn: updateRegistration,
    onError: (data) => {
      const { errorCode } = data
      setMessage(
        errorCode
          ? t(`errors.${errorCode}`)
          : t('registrations.flash.failed') + data.message,
        'negative',
      )
    },
  })

  const attemptToApprove = () => {
    const idsToAccept = [...pending, ...cancelled, ...waiting]
    if (idsToAccept.length > spotsRemaining) {
      setMessage(
        t('competitions.registration_v2.update.tooMany', {
          count: idsToAccept.length - spotsRemaining,
        }),
        'negative',
      )
    } else {
      changeStatus(idsToAccept, 'accepted')
    }
  }

  const changeStatus = (attendees, status) => {
    attendees.forEach(async (attendee) => {
      await updateRegistrationMutation(
        {
          user_id: attendee,
          competing: {
            status,
          },
          competition_id: competitionInfo.id,
        },
        {
          onSuccess: () => {
            setMessage(t('registrations.flash.updated'), 'positive')
            refresh()
          },
        },
      )
    })
  }

  const copyEmails = (emails) => {
    navigator.clipboard.writeText(emails)
    setMessage('Copied to clipboard. Remember to use bcc!', 'positive')
  }

  return (
    anySelected && (
      <Button.Group className={styles.actions}>
        <Button
          onClick={() => {
            csvExport(
              [...pending, ...accepted, ...cancelled, ...waiting],
              registrations,
            )
          }}
        >
          <UiIcon name="download" /> {t('registrations.list.export_csv')}
        </Button>

        <Button>
          <a
            href={`mailto:?bcc=${selectedEmails}`}
            id="email-selected"
            target="_blank"
            className="btn btn-info selected-registrations-actions"
          >
            <UiIcon name="envelope" />
            {t('competitions.registration_v2.update.emailSend')}
          </a>
        </Button>

        <Button onClick={() => copyEmails(selectedEmails)}>
          <UiIcon name="copy" />
          {t('competitions.registration_v2.update.emailCopy')}
        </Button>

        {isOrganizerOrDelegate && (
          <>
            {anyApprovable && (
              <Button positive onClick={attemptToApprove}>
                <UiIcon name="check" />
                {t('registrations.list.approve')}
              </Button>
            )}

            {anyRejectable && (
              <Button
                onClick={() =>
                  changeStatus(
                    [...accepted, ...cancelled, ...waiting],
                    'pending',
                  )
                }
              >
                <UiIcon name="times" />
                {t('competitions.registration_v2.update.movePending')}
              </Button>
            )}

            {anyWaitlistable && (
              <Button
                color="yellow"
                onClick={() =>
                  changeStatus(
                    [...pending, ...cancelled, ...accepted],
                    'waiting_list',
                  )
                }
              >
                <UiIcon name="hourglass" />
                {t('competitions.registration_v2.update.moveWaiting')}
              </Button>
            )}

            {anyCancellable && (
              <Button
                negative
                onClick={() =>
                  changeStatus(
                    [...pending, ...accepted, ...waiting],
                    'cancelled',
                  )
                }
              >
                <UiIcon name="trash" />
                {t('competitions.registration_v2.update.cancel')}
              </Button>
            )}
          </>
        )}
      </Button.Group>
    )
  )
}
