import createClient from 'openapi-fetch'
import { getJWT } from '../../auth/get_jwt'
import { BackendError, EXPIRED_TOKEN } from '../../helper/error_codes'
import { components, paths } from '../../schema'

const { GET } = createClient<paths>({
  baseUrl: process.env.API_URL,
})

type RegistrationPublic = components['schemas']['registration']
type RegistrationAdmin = components['schemas']['registrationAdmin']
type CompetitorList = RegistrationPublic[]
type CompetitorAdministrationList = RegistrationAdmin[]
type WaitingList = components['schemas']['waitingList']

export async function getConfirmedRegistrations(
  competitionID: string,
): Promise<CompetitorList> {
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

type PsychSheet = components['schemas']['psychSheet']

export async function getPsychSheetForEvent(
  competitionId: string,
  eventId: string,
  sortBy: string,
): Promise<PsychSheet> {
  const { data, response } = await GET(
    '/api/v1/psych_sheet/{competition_id}/{event_id}',
    {
      params: {
        path: { competition_id: competitionId, event_id: eventId },
        query: { sort_by: sortBy },
      },
    },
  )
  if (!response.ok) {
    throw new BackendError(500, response.status)
  }
  return data!
}

export async function getAllRegistrations(
  competitionID: string,
): Promise<CompetitorAdministrationList> {
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
): Promise<RegistrationAdmin> {
  const { data, error, response } = await GET('/api/v1/register', {
    params: { query: { competition_id: competitionId, user_id: userId } },
    headers: { Authorization: await getJWT() },
  })
  if (error) {
    if (error.error === EXPIRED_TOKEN) {
      await getJWT(true)
      return getSingleRegistration(userId, competitionId)
    }
    throw new BackendError(error.error, response.status)
  }

  return data!
}

export async function getWaitingCompetitors(
  competitionId: string,
): Promise<WaitingList> {
  const { data, error, response } = await GET(
    '/api/v1/registrations/{competition_id}/waiting',
    {
      params: { path: { competition_id: competitionId } },
      headers: { Authorization: await getJWT() },
    },
  )
  if (error) {
    if (error.error === EXPIRED_TOKEN) {
      await getJWT(true)
      return getWaitingCompetitors(competitionId)
    }
    throw new BackendError(error.error, response.status)
  }

  return data!
}
