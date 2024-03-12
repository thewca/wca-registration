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
  // safeguard for when there is nothing to query.
  // Rails blows up with an empty param array so we cannot do this check in the backend.
  if (userIds.length === 0) {
    return [];
  }

  const { data, error, response } = await POST('/api/v1/users', {
    body: { ids: userIds },
  })
  if (!data) {
    throw new BackendError(error.error, response.status)
  }
  return data
}
