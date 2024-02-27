import createClient from 'openapi-fetch'
import { getJWT } from '../../auth/get_jwt'
import { BackendError, EXPIRED_TOKEN } from '../../helper/error_codes'
import { components, paths } from '../../schema'

const { PATCH } = createClient<paths>({
  baseUrl: process.env.API_URL,
})

export async function updateRegistration(
  body: components['schemas']['updateRegistrationBody'],
): Promise<{
  status?: string
  registration?: components['schemas']['registrationAdmin']
}> {
  const { data, error, response } = await PATCH('/api/v1/register', {
    headers: { Authorization: await getJWT() },
    body,
  })
  if (error) {
    if (error.error === EXPIRED_TOKEN) {
      await getJWT(true)
      return updateRegistration(body)
    }
    throw new BackendError(error.error, response.status)
  }
  return data
}
