import { EventId } from '@wca/helpers'
import backendFetch from '../../helper/backend_fetch'
import { SubmitRegistrationBody } from '../../types'

export default async function submitEventRegistration(
  competitorId: string,
  competitionId: string,
  comment: string,
  events: EventId[]
) {
  const body: SubmitRegistrationBody = {
    competitor_id: competitorId,
    competition_id: competitionId,
    event_ids: events,
    comment,
  }

  return backendFetch('/register', 'POST', body)
}
