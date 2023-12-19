import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { Message } from 'semantic-ui-react'
import getCompetitionWcif from '../../api/competition/get/get_competition_wcif'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { setMessage } from '../../ui/events/messages'
import LoadingMessage from '../../ui/messages/loadingMessage'
import Schedule from './Schedule'

export default function ScheduleTab() {
  const { competitionInfo } = useContext(CompetitionContext)

  const {
    isLoading,
    isError,
    data: wcif,
  } = useQuery({
    queryKey: ['wcif', competitionInfo.id],
    queryFn: () => getCompetitionWcif(competitionInfo.id),
    retry: false,
    onError: (err) => setMessage(err.message, 'error'),
  })

  if (isLoading) {
    return <LoadingMessage />
  }

  if (isError) {
    return <Message>Loading the schedule failed, please try again.</Message>
  }

  return <Schedule wcif={wcif} />
}
