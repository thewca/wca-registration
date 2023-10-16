import createClient from 'openapi-fetch'
import { getJWT } from '../../auth/get_jwt'
import { BackendError } from '../../helper/backend_fetch'
import { EXPIRED_TOKEN } from '../../helper/error_codes'
import { components, paths } from '../../schema'

const { POST } = createClient<paths>({
  // TODO: Change this once we are fully migrated from backend fetch
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  baseUrl: process.env.API_URL.slice(0, -7),
})
export default async function submitEventRegistration(
  body: components['schemas']['submitRegistrationBody']
): Promise<components['schemas']['success_response']> {
  const { data, error, response } = await POST('/api/v1/register', {
    headers: { Authorization: await getJWT() },
    body,
  })
  if (error) {
    if (error.error === EXPIRED_TOKEN) {
      await getJWT(true)
      return submitEventRegistration(body)
    }
    throw new BackendError(error.error, response.status)
  }
  return data
}
