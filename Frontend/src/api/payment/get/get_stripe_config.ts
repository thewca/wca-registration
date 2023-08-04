import externalServiceFetch from '../../helper/external_service_fetch'
import getStripeConfigMock from '../../mocks/get_stripe_config'

export interface StripeConfig {
  stripe_publishable_key: string
  connected_account_id: string
}

export default async function getStripeConfig(
  competitionId: string
): Promise<StripeConfig> {
  if (process.env.NODE_ENV === 'production') {
    // This should live in the payment service?
    return externalServiceFetch(
      `https://test-registration.worldcubeassociation.org/api/v10/payment/${competitionId}/config`
    )
  }

  return getStripeConfigMock()
}
