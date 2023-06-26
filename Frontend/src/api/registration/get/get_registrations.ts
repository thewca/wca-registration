import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'

type RegistrationStatus = 'waiting' | 'accepted' | 'deleted'

interface Registration {
  user_id: string
  event_ids: EventId[]
}

interface RegistrationAdmin {
  user_id: string
  event_ids: EventId[]
  registration_status: RegistrationStatus
  registered_on: string
  comment: string
}

export async function getConfirmedRegistrations(
  competitionID: string
): Promise<Registration[]> {
  return backendFetch(`/registrations/${competitionID}`, 'GET')
}

export async function getAllRegistrations(
  competitionID: string
): Promise<RegistrationAdmin[]> {
  return backendFetch(`/registrations/${competitionID}/admin`, 'GET')
}

export async function getSingleRegistration(
  userId: string,
  competitionId: string
): Promise<{ registration: RegistrationAdmin }> {
  return backendFetch(
    `/register?user_id=${userId}&competition_id=${competitionId}`,
    'GET'
  )
}
