import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'
import { UpdateRegistrationBody } from '../../types'

export async function updateRegistration(
  competitorID: string,
  competitionID: string,
  status?: string,
  eventIds?: EventId[],
  comment?: string
) {
  const body: UpdateRegistrationBody = {
    competitor_id: competitorID,
    competition_id: competitionID,
    event_ids: eventIds,
    comment,
    status,
  }

  return backendFetch('/register', 'PATCH', body)
}
