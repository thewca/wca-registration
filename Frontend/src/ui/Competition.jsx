import { useQuery } from '@tanstack/react-query'
import React from 'react'
import { useParams } from 'react-router-dom'
import getCompetitionInfo from '../api/competition/get/get_competition_info'
import { CompetitionContext } from '../api/helper/context/competition_context'
import LoadingMessage from './messages/loadingMessage'

export default function Competition({ children }) {
  const { competition_id } = useParams()
  const { isLoading, data } = useQuery({
    queryKey: [competition_id],
    queryFn: () => getCompetitionInfo(competition_id),
  })
  return (
    <CompetitionContext.Provider value={{ competitionInfo: data ?? {} }}>
      {isLoading ? <LoadingMessage /> : children}
    </CompetitionContext.Provider>
  )
}
