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
  // There is a weird error here that this is undefined when you reload on lower pages
  useEffect(() => {
    setCompetitionInfo(data)
  }, [data])
  return (
    <CompetitionContext.Provider value={{ competitionInfo }}>
      {children}
    </CompetitionContext.Provider>
  )
}
