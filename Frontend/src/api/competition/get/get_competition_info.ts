import externalServiceFetch from '../../helper/external_service_fetch'
import { competitionInfoRoute } from '../../helper/routes'
import getCompetitionInfoMockWithRealFallback from '../../mocks/get_competition_info'
import { CompetitionInfo } from '../../types'

export default async function getCompetitionInfo(
  competitionId: string,
): Promise<CompetitionInfo> {
  if (process.env.NODE_ENV !== 'production') {
    return getCompetitionInfoMockWithRealFallback(competitionId)
  }
  return externalServiceFetch(competitionInfoRoute(competitionId))
}
