import { EventId } from '@wca/helpers'
import externalServiceFetch from '../../helper/external_service_fetch'

interface CompetitionInfo {
  id: string
  name: string
  url: string
  event_ids: EventId[]
}
export default async function getCompetitionInfo(
  competitionId: string
): Promise<CompetitionInfo> {
  return externalServiceFetch(
    `https://www.worldcubeassociation.org/api/v0/competitions/${competitionId}`
  )
}
