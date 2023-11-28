import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { Table, TableFooter } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getWaitingCompetitors } from '../../../api/registration/get/get_registrations'
import { setMessage } from '../../../ui/events/messages'
import LoadingMessage from '../../../ui/messages/loadingMessage'

export default function WaitingList() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { isLoading, data: waiting } = useQuery({
    queryKey: ['waiting', competitionInfo.id],
    queryFn: () => getWaitingCompetitors(competitionInfo.id),
    retry: false,
    onError: (err) => {
      setMessage(err.message, 'error')
    },
  })
  return isLoading ? (
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
        {waiting ? (
          waiting
            .sort(
              (w1, w2) =>
                w1.competing.waiting_list_position -
                w2.competing.waiting_list_position
            )
            .map((w) => (
              <Table.Row key={w.user_id}>
                <Table.Cell>{w.user.name}</Table.Cell>
                <Table.Cell>
                  {w.competing.waiting_list_position === 0
                    ? 'Not yet assigned'
                    : w.competing.waiting_list_position}
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
