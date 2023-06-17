import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'
import { UpdateRegistrationBody } from '../../types'

export async function updateRegistrationStatus(
  competitorID: string,
  competitionID: string,
  status: string
) {
  const body: UpdateRegistrationBody = {
    competitor_id: competitorID,
    competition_id: competitionID,
    status,
  }

  return backendFetch('/register', 'PATCH', body)
}

export async function updateRegistrationEvents(
  competitorID: string,
  competitionID: string,
  eventIds: EventId[],
  comment: string
) {
  const body: UpdateRegistrationBody = {
    competitor_id: competitorID,
    competition_id: competitionID,
    event_ids: eventIds,
    comment,
  }

  return backendFetch('/register', 'PATCH', body)
}
