import createClient from 'openapi-fetch'
import { BackendError } from '../../helper/backend_fetch'
import { components, paths } from '../../schema'

const { POST } = createClient<paths>({
  // TODO: Change this once we are fully migrated from backend fetch
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  baseUrl: process.env.API_URL.slice(0, -7),
})

export async function getCompetitorInfo(
  userId: number
): Promise<components['schemas']['userInfo']> {
  return (await getCompetitorsInfo([userId]))[0]
}

export async function getCompetitorsInfo(
  userIds: number[]
): Promise<components['schemas']['userInfo'][]> {
  const { data, error, response } = await POST('/api/v1/users', {
    body: { ids: userIds },
  })
  if (!data) {
    throw new BackendError(error, response.status)
  }
  return data
}
