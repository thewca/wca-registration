import externalServiceFetch from '../../helper/external_service_fetch'
import { CompetitionInfo } from '../../types'

export default async function getCompetitionInfo(
  competitionId: string
): Promise<CompetitionInfo> {
  return externalServiceFetch(
    `https://www.worldcubeassociation.org/api/v0/competitions/${competitionId}`
  )
}
