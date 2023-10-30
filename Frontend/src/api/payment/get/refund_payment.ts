import externalServiceFetch from '../../helper/external_service_fetch'
import { refundRoute } from '../../helper/routes'

export default async function refundPayment(
  competitionId: string,
  userId: string,
  paymentId: string
): Promise<{
  payment_id: string
  amount: number
}> {
  return externalServiceFetch(refundRoute(competitionId, userId, paymentId))
}
