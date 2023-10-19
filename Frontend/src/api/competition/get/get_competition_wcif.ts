import { Competition } from '@wca/helpers'
import externalServiceFetch from '../../helper/external_service_fetch'
import { competitionWCIFRoute } from '../../helper/routes'

export default async function getCompetitionWcif(
  competitionId: string
): Promise<Competition> {
  return externalServiceFetch(competitionWCIFRoute(competitionId))
}
