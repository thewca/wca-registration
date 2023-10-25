import externalServiceFetch from '../../helper/external_service_fetch'
import { paymentConfigRoute } from '../../helper/routes'

export interface StripeConfig {
  stripe_publishable_key: string
  connected_account_id: string
  client_secret: string
}

export default async function getStripeConfig(
  competitionId: string,
  paymentId: string
): Promise<StripeConfig> {
  return externalServiceFetch(paymentConfigRoute, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      competition_id: competitionId,
      payment_id: paymentId,
    }),
  })
}
