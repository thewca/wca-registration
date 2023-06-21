import { EventId } from '@wca/helpers'
import { useEffect, useState } from 'react'
import getCompetitionInfo from '../competition/get/get_competition_info'
import getCompetitorInfo, { CompetitorInfo } from '../user/get/get_user_info'

export function useHeldEvents(competitionId: string) {
  const [isLoading, setIsLoading] = useState<boolean>(true)
  const [heldEvents, setHeldEvents] = useState<EventId[]>([])

  useEffect(() => {
    getCompetitionInfo(competitionId).then((competitionInfo) => {
      setHeldEvents(competitionInfo.event_ids)
      setIsLoading(false)
    })
  }, [competitionId])

  return { isLoading, heldEvents }
}

export function useCompetitorInfo(userId: string) {
  const [isLoading, setIsLoading] = useState<boolean>(true)
  const [competitorInfo, setCompetitorInfo] = useState<CompetitorInfo | object>(
    {}
  )

  useEffect(() => {
    getCompetitorInfo(userId).then((competitorInfo) => {
      setCompetitorInfo(competitorInfo)
      setIsLoading(false)
    })
  }, [userId])

  return { isLoading, competitorInfo }
}
