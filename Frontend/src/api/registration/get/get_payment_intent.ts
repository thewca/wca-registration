import createClient from 'openapi-fetch'
import { getJWT } from '../../auth/get_jwt'
import { BackendError, EXPIRED_TOKEN } from '../../helper/error_codes'
import { components, paths } from '../../schema'

const { GET } = createClient<paths>({
  baseUrl: process.env.API_URL,
})

type PaymentInfo = components['schemas']['paymentInfo']
export default async function getPaymentId(
  competitionId: string,
): Promise<PaymentInfo> {
  const { data, error, response } = await GET(
    '/api/v1/{competition_id}/payment',
    {
      params: { path: { competition_id: competitionId } },
      headers: { Authorization: await getJWT() },
    },
  )
  if (error) {
    if (error.error === EXPIRED_TOKEN) {
      await getJWT(true)
      return getPaymentId(competitionId)
    }
    throw new BackendError(error.error, response.status)
  }

  return data!
}
