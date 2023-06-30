import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'
import { UpdateRegistrationBody } from '../../types'
import { RegistrationAdmin } from '../get/get_registrations'

export async function updateRegistration(
  competitorID: string,
  competitionID: string,
  options: {
    status?: string
    eventIds?: EventId[]
    comment?: string
  }
) {
  const body: UpdateRegistrationBody = {
    user_id: competitorID,
    competition_id: competitionID,
    event_ids: options.eventIds,
    comment: options.comment,
    status: options.status,
  }

  return backendFetch('/register', 'PATCH', {
    body,
    needsAuthentication: true,
  }) as Promise<{ registration: RegistrationAdmin }>
}
