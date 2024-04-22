import { Competition } from '@wca/helpers'
import externalServiceFetch from '../../helper/external_service_fetch'
import { competitionWCIFRoute } from '../../helper/routes'
import getWcifMockWithRealFallback from '../../mocks/get_wcif'

export default async function getCompetitionWcif(
  competitionId: string,
): Promise<Competition> {
  if (process.env.NODE_ENV !== 'production') {
    return getWcifMockWithRealFallback(competitionId)
  }
  return externalServiceFetch(competitionWCIFRoute(competitionId))
}
