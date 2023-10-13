import createClient from 'openapi-fetch'
import backendFetch, { BackendError } from '../../helper/backend_fetch'
import { components, paths } from '../../schema'
import getCompetitorInfo from '../../user/get/get_user_info'

const { get } = createClient<paths>({
  // TODO: Change this once we are fully migrated from backend fetch
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  baseUrl: process.env.API_URL.slice(0, -7),
})

export async function getConfirmedRegistrations(
  competitionID: string
): Promise<components['schemas']['registration'][]> {
  //TODO: Because there is currently no bulk user fetch route we need to manually add user data here
  const { data, response } = await get(
    '/api/v1/registrations/{competition_id}',
    {
      params: { path: { competition_id: competitionID } },
    }
  )
  const regList = []
  if (!response.ok) {
    throw new BackendError(500, response.status)
  }
  for (const registration of data!) {
    const user = (await getCompetitorInfo(registration.user_id)).user
    regList.push({
      user_id: registration.user_id,
      competing: registration.competing,
      user,
    })
  }
  return regList
}

export async function getAllRegistrations(
  competitionID: string
): Promise<components['schemas']['registrationAdmin'][]> {
  //TODO: Because there is currently no bulk user fetch route we need to manually add user data here
  const { data, response } = await get(
    '/api/v1/registrations/{competition_id}/admin',
    {
      params: { path: { competition_id: competitionID } },
    }
  )
  const regList = []
  if (!response.ok) {
    throw new BackendError(500, response.status)
  }
  for (const registration of data!) {
    const user = (await getCompetitorInfo(registration.user_id)).user
    regList.push({
      user_id: registration.user_id,
      competing: registration.competing,
      user,
    })
  }
  return regList
}

export async function getSingleRegistration(
  userId: string,
  competitionId: string
): Promise<{ registration: components['schemas']['registrationAdmin'] }> {
  return backendFetch(
    `/register?user_id=${userId}&competition_id=${competitionId}`,
    'GET',
    { needsAuthentication: true }
  ) as Promise<{ registration: components['schemas']['registrationAdmin'] }>
}
