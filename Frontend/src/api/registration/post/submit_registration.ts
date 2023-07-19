import createClient from 'openapi-fetch'
import { getJWT } from '../../auth/get_jwt'
import { components, paths } from '../../schema'
import { BackendError } from '../../helper/backend_fetch'
import { EXPIRED_TOKEN } from '../../helper/error_codes'

const { post } = createClient<paths>({
  // TODO: Change this once we are fully migrated from backend fetch
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  baseUrl: process.env.API_URL.slice(0, -7),
})
export default async function submitEventRegistration(
  body: components['schemas']['submitRegistrationBody']
): Promise<components['schemas']['success_response']> {
  const token = await getJWT()
  const { data, error, response } = await post('/api/v1/register', {
    // TODO: I think this is a bug in open-api fetch https://github.com/drwpow/openapi-typescript/issues/1230
    params: { header: { Authorization: token } },
    headers: { Authorization: token },
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
