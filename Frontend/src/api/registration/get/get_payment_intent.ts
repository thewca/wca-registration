import backendFetch from '../../helper/backend_fetch'
import { paymentIdRoute } from '../../helper/routes'

export interface PaymentInfo {
  // This is the MySQL payment id that can be give to the payment service
  // to get the relevant data, not the Stripe ID!
  payment_id: string
}
// We get the user_id out of the JWT key, which is why we only send the
// competition_id
export default async function getPaymentId(
  competitionId: string
): Promise<PaymentInfo> {
  return backendFetch(paymentIdRoute(competitionId), 'GET', {
    needsAuthentication: true,
  }) as Promise<PaymentInfo>
}
