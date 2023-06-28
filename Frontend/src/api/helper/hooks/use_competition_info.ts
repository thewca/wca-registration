import { useEffect, useState } from 'react'
import getCompetitionInfo from '../../competition/get/get_competition_info'
import { CompetitionInfo } from '../../types'

export function useHeldEvents(competitionId: string) {
  const { isLoading, competitionInfo } = useCompetitionInfo(competitionId)
  const heldEvents = competitionInfo.event_ids
  return { isLoading, heldEvents }
}

export function useCompetitionInfo(competitionId: string) {
  const [competitionInfo, setCompetitionInfo] = useState<CompetitionInfo>({
    announced_at: '',
    cancelled_at: '',
    city: '',
    class: '',
    competitor_limit: 0,
    country_iso2: '',
    delegates: [],
    end_date: '',
    event_ids: [],
    id: '',
    latitude_degrees: 0,
    longitude_degrees: 0,
    name: '',
    organizers: [],
    registration_close: '',
    registration_open: '',
    short_name: '',
    start_date: '',
    url: '',
    venue_address: '',
    venue_details: '',
    website: '',
  })
  const [isLoading, setIsLoading] = useState<boolean>(true)
  useEffect(() => {
    getCompetitionInfo(competitionId).then(
      (competitionInfo: CompetitionInfo) => {
        setCompetitionInfo(competitionInfo)
        setIsLoading(false)
      }
    )
  }, [competitionId])
  return { isLoading, competitionInfo }
}
