import backendFetch from '../../helper/backend_fetch'
import getPaymentIntentMock from '../../mocks/get_payment_intent'

export interface PaymentInfo {
  client_secret_id: string
}
// We get the user_id out of the JWT key, which is why we only send the
// competition_id
export default async function getPaymentIntent(
  competitionId: string
): Promise<PaymentInfo> {
  if (process.env.NODE_ENV === 'production') {
    // This should live in the payment service?
    return backendFetch(`/${competitionId}/payment`, 'GET', {
      needsAuthentication: true,
    }) as Promise<PaymentInfo>
  }
  return getPaymentIntentMock()
}
