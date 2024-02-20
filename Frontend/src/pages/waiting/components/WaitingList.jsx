import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { useTranslation } from 'react-i18next'
import { Table, TableFooter } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getWaitingCompetitors } from '../../../api/registration/get/get_registrations'
import { useWithUserData } from '../../../hooks/useUserData'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'

export default function WaitingList() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { t } = useTranslation()
  const { isLoading: waitingLoading, data: waiting } = useQuery({
    queryKey: ['waiting', competitionInfo.id],
    queryFn: () => getWaitingCompetitors(competitionInfo.id),
    retry: false,
    onError: (err) => {
      const { errorCode } = err
      setMessage(
        errorCode
          ? t(`errors.${errorCode}`)
          : 'Fetching Registrations failed with error: ' + err.message,
        'negative',
      )
    },
  })

  const { isLoading: infoLoading, data: registrationsWithUser } = useWithUserData(waiting ?? [])

  return waitingLoading || infoLoading ? (
    <LoadingMessage />
  ) : (
    <Table>
      <Table.Header>
        <Table.Row>
          <Table.HeaderCell>Name</Table.HeaderCell>
          <Table.HeaderCell>Position</Table.HeaderCell>
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {registrationsWithUser?.length ? (
          registrationsWithUser
            .sort(
              (w1, w2) =>
                w1.competing.waiting_list_position -
                w2.competing.waiting_list_position,
            ) // Once a waiting list is established, we just care about the order of the waitlisted competitors
            .map((w, i) => (
              <Table.Row key={w.user_id}>
                <Table.Cell>{w.user.name}</Table.Cell>
                <Table.Cell>
                  {w.competing.waiting_list_position === 0
                    ? 'Not yet assigned'
                    : i + 1}
                </Table.Cell>
              </Table.Row>
            ))
        ) : (
          <TableFooter>No one on the Waiting List.</TableFooter>
        )}
      </Table.Body>
    </Table>
  )
}
