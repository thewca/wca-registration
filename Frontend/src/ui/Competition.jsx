import { useQuery } from '@tanstack/react-query'
import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import getCompetitionInfo from '../api/competition/get/get_competition_info'
import { CompetitionContext } from '../api/helper/context/competition_context'

export default function Competition({ children }) {
  const { competition_id } = useParams()
  const { data } = useQuery({
    queryKey: [competition_id],
    queryFn: () => getCompetitionInfo(competition_id),
  })
  const [competitionInfo, setCompetitionInfo] = useState({})
  useEffect(() => {
    if (data) {
      setCompetitionInfo(data)
    }
  }, [data])
  return (
    <CompetitionContext.Provider value={{ competitionInfo }}>
      {children}
    </CompetitionContext.Provider>
  )
}
