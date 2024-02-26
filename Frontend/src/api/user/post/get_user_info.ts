import createClient from 'openapi-fetch'
import { BackendError } from '../../helper/error_codes'
import { components, paths } from '../../schema'

const { POST } = createClient<paths>({
  // TODO: Change this once we are fully migrated from backend fetch
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  baseUrl: process.env.API_URL.slice(0, -7),
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
