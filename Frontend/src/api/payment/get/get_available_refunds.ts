import externalServiceFetch from '../../helper/external_service_fetch'
import { availableRefundsRoute } from '../../helper/routes'

export default async function getAvailableRefunds(
  competitionId: string,
  userId: string
): Promise<{
  charges: { payment_id: string; amount: number }[]
}> {
  return externalServiceFetch(availableRefundsRoute(competitionId, userId))
}
