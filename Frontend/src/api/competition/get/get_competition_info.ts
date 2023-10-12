import externalServiceFetch from '../../helper/external_service_fetch'
import { competitionInfoRoute } from '../../helper/routes'
import { CompetitionInfo } from '../../types'

export default async function getCompetitionInfo(
  competitionId: string
): Promise<CompetitionInfo> {
  return externalServiceFetch(competitionInfoRoute(competitionId))
}
