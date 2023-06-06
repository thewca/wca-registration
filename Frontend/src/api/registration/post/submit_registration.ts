import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'
import { SubmitRegistrationBody } from '../../types'

export default async function submitEventRegistration(
  competitorId: string,
  competitionId: string,
  events: EventId[]
) {
  const body: SubmitRegistrationBody = {
    competitor_id: competitorId,
    competition_id: competitionId,
    event_ids: events,
  }

  return backendFetch('/register', 'POST', body)
}
