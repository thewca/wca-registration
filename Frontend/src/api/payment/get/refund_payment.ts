import externalServiceFetch from '../../helper/external_service_fetch'
import { refundRoute } from '../../helper/routes'

export default async function refundPayment(body: {
  competitionId: string
  userId: string
  paymentId: string
  amount: number
}): Promise<{
  status: string
}> {
  return externalServiceFetch(
    refundRoute(body.competitionId, body.userId, body.paymentId, body.amount)
  )
}
