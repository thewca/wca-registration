import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'
import { ErrorResponse } from '../../types'

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
): Promise<Registration[] | ErrorResponse> {
  return backendFetch(`/registrations/${competitionID}`, 'GET', {
    needsAuthentication: false,
  })
}

export async function getAllRegistrations(
  competitionID: string
): Promise<RegistrationAdmin[] | ErrorResponse> {
  return backendFetch(`/registrations/${competitionID}/admin`, 'GET', {
    needsAuthentication: true,
  })
}

export async function getSingleRegistration(
  userId: string,
  competitionId: string
): Promise<{ registration: RegistrationAdmin } | ErrorResponse> {
  return backendFetch(
    `/register?user_id=${userId}&competition_id=${competitionId}`,
    'GET',
    { needsAuthentication: true }
  )
}
