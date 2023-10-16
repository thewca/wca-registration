import createClient from 'openapi-fetch'
import { components, paths } from '../../schema'
import { EXPIRED_TOKEN } from '../../helper/error_codes'
import { getJWT } from '../../auth/get_jwt'
import { BackendError } from '../../helper/backend_fetch'

const { PATCH } = createClient<paths>({
  // TODO: Change this once we are fully migrated from backend fetch
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  baseUrl: process.env.API_URL.slice(0, -7),
})

export async function updateRegistration(
  body: components['schemas']['updateRegistrationBody']
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
