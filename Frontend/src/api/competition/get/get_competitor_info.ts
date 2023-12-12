import externalServiceFetch from '../../helper/external_service_fetch'
import { competitorInfoRoute } from '../../helper/routes'
import getCompetitorInfoMock from '../../mocks/get_competitor_info'
import { CompetitorInfo } from '../../types'

export default async function getCompetitorInfo(
  competitionId: string
): Promise<CompetitorInfo[]> {
  if (process.env.NODE_ENV !== 'production') {
    return getCompetitorInfoMock(competitionId)
  }
  return externalServiceFetch(competitorInfoRoute(competitionId))
}
