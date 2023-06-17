import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'

type RegistrationStatus = 'waiting' | 'accepted' | 'deleted'

interface Registration {
  competitor_id: string
  event_ids: EventId[]
}

interface RegistrationAdmin {
  competitor_id: string
  event_ids: EventId[]
  registration_status: RegistrationStatus
  registered_on: string
  comment: string
}

export async function getConfirmedRegistrations(
  competitionID: string
): Promise<Registration[]> {
  return backendFetch(`/registrations?competition_id=${competitionID}`, 'GET')
}

export async function getAllRegistrations(
  competitionID: string
): Promise<RegistrationAdmin[]> {
  return backendFetch(
    `/registrations/admin?competition_id=${competitionID}`,
    'GET'
  )
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
