import createClient from 'openapi-fetch'
import { getJWT } from '../../auth/get_jwt'
import backendFetch, { BackendError } from '../../helper/backend_fetch'
import { EXPIRED_TOKEN } from '../../helper/error_codes'
import { components, paths } from '../../schema'

const { GET } = createClient<paths>({
  // TODO: Change this once we are fully migrated from backend fetch
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  baseUrl: process.env.API_URL.slice(0, -7),
})

export async function getConfirmedRegistrations(
  competitionID: string,
): Promise<components['schemas']['registration'][]> {
  const { data, response } = await GET(
    '/api/v1/registrations/{competition_id}',
    {
      params: { path: { competition_id: competitionID } },
    },
  )
  if (!response.ok) {
    throw new BackendError(500, response.status)
  }
  return data!
}

export async function getPsychSheetForEvent(
  competitionId: string,
  eventId: string,
  sortBy: string,
): Promise<components['schemas']['psychSheet']> {
  //TODO: Because there is currently no bulk user fetch route we need to manually add user data here
  const { data, response } = await GET(
    '/api/v1/psych_sheet/{competition_id}/{event_id}',
    {
      params: { path: { competition_id: competitionId, event_id: eventId }, query: { sort_by: sortBy } },
    }
  )
  if (!response.ok) {
    throw new BackendError(500, response.status)
  }
  return data!
}

export async function getAllRegistrations(
  competitionID: string,
): Promise<components['schemas']['registrationAdmin'][]> {
  const { data, error, response } = await GET(
    '/api/v1/registrations/{competition_id}/admin',
    {
      params: { path: { competition_id: competitionID } },
      headers: { Authorization: await getJWT() },
    },
  )
  if (error) {
    if (error.error === EXPIRED_TOKEN) {
      await getJWT(true)
      return getAllRegistrations(competitionID)
    }
    throw new BackendError(error.error, response.status)
  }

  return data!
}

export async function getSingleRegistration(
  userId: number,
  competitionId: string,
): Promise<{ registration: components['schemas']['registrationAdmin'] }> {
  return (await backendFetch(
    `/register?user_id=${userId}&competition_id=${competitionId}`,
    'GET',
    { needsAuthentication: true },
  )) as { registration: components['schemas']['registrationAdmin'] }
}

export async function getWaitingCompetitors(
  competitionId: string,
): Promise<components['schemas']['registrationAdmin'][]> {
  return (await backendFetch(`/registrations/${competitionId}/waiting`, 'GET', {
    needsAuthentication: false,
  })) as components['schemas']['registrationAdmin'][]
}
