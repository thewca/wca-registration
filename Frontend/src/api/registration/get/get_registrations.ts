import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'
import getCompetitorInfo, { User } from '../../user/get/get_user_info'

type RegistrationStatus = 'waiting' | 'accepted' | 'deleted'

interface Registration {
  user_id: string
  user: User
  event_ids: EventId[]
}

interface RegistrationAdmin {
  user_id: string
  event_ids: EventId[]
  registration_status: RegistrationStatus
  registered_on: string
  comment: string
  user: User
}

export async function getConfirmedRegistrations(
  competitionID: string
): Promise<Registration[]> {
  //TODO: Because there is currently no bulk user fetch route we need to manually add user data here
  const registrations = (await backendFetch(
    `/registrations/${competitionID}`,
    'GET',
    {
      needsAuthentication: false,
    }
  )) as Registration[]
  const regList = []
  for (const registration of registrations) {
    registration.user = (await getCompetitorInfo(registration.user_id)).user
    regList.push(registration)
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
