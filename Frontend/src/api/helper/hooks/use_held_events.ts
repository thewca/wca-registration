import { EventId } from '@wca/helpers'
import { useEffect, useState } from 'react'
import getCompetitionInfo from '../../competition/get/get_competition_info'

export default function useHeldEvents(competitionId: string) {
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
