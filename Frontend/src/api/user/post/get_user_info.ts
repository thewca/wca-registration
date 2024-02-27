import createClient from 'openapi-fetch'
import { BackendError } from '../../helper/error_codes'
import { components, paths } from '../../schema'

const { POST } = createClient<paths>({
  baseUrl: process.env.API_URL,
})

export async function getUserInfo(
  userId: number,
): Promise<components['schemas']['userInfo']> {
  return (await getUsersInfo([userId]))[0]
}

export async function getUsersInfo(
  userIds: number[],
): Promise<components['schemas']['userInfo'][]> {
  const { data, error, response } = await POST('/api/v1/users', {
    body: { ids: userIds },
  })
  if (!data) {
    throw new BackendError(error.error, response.status)
  }
  return data
}
