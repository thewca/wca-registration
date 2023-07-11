import { EventId } from '@wca/helpers'
import createClient from 'openapi-fetch'
import backendFetch, { BackendError } from '../../helper/backend_fetch'
import { paths } from '../../schema'
import getCompetitorInfo, { User } from '../../user/get/get_user_info'

const { get } = createClient<paths>({
  // TODO: Change this once we are fully migrated from backend fetch
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  baseUrl: process.env.API_URL.slice(0, -7),
})

type RegistrationStatus = 'waiting' | 'accepted' | 'deleted'

interface Registration {
  user_id: string
  user: User
  event_ids: EventId[]
}

export interface RegistrationAdmin {
  user_id: string
  event_ids: EventId[]
  registration_status: RegistrationStatus
  registered_on: string
  comment: string
  admin_comment: string
  guests: number
  user: User
}

export async function getConfirmedRegistrations(
  competitionID: string
): Promise<Registration[]> {
  //TODO: Because there is currently no bulk user fetch route we need to manually add user data here
  const { data, error, response } = await get(
    '/api/v1/registrations/{competition_id}',
    {
      params: { path: { competition_id: competitionID } },
    }
  )
  const regList = []
  if (error) {
    throw new BackendError(error.error, response.status)
  }
  for (const registration of data) {
    const user = (await getCompetitorInfo(registration.user_id)).user
    regList.push({
      user_id: registration.user_id,
      event_ids: registration.event_ids,
      user,
    })
  }
  return regList
}

export async function getAllRegistrations(
  competitionID: string
): Promise<RegistrationAdmin[]> {
  //TODO: Because there is currently no bulk user fetch route we need to manually add user data here
  const registrations = (await backendFetch(
    `/registrations/${competitionID}/admin`,
    'GET',
    {
      needsAuthentication: true,
    }
  )) as RegistrationAdmin[]
  const regList = []
  for (const registration of registrations) {
    registration.user = (await getCompetitorInfo(registration.user_id)).user
    regList.push(registration)
  }
  return regList
}

export async function getSingleRegistration(
  userId: string,
  competitionId: string
): Promise<{ registration: RegistrationAdmin }> {
  return backendFetch(
    `/register?user_id=${userId}&competition_id=${competitionId}`,
    'GET',
    { needsAuthentication: true }
  ) as Promise<{ registration: RegistrationAdmin }>
}
