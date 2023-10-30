import { useQuery } from '@tanstack/react-query'
import { useContext } from 'react'
import { Table } from 'semantic-ui-react'
import { CompetitionContext } from '../../../api/helper/context/competition_context'
import { getWaitingCompetitors } from '../../../api/registration/get/get_waiting'
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
        {waiting.map((w, i) => (
          <Table.Row key={w.user_id}>
            <Table.Cell>{w.user_id}</Table.Cell>
            <Table.Cell>{i}</Table.Cell>
          </Table.Row>
        ))}
      </Table.Body>
    </Table>
  )
}
