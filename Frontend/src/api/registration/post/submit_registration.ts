import backendFetch from '../../helper/backend_fetch'

export default async function submitEventRegistration(
  competitorId: string,
  competitionId: string,
  events: WCAEvent[]
) {
  const body: SubmitRegistrationBody = {
    competitor_id: competitorId,
    competition_id: competitionId,
    event_ids: events,
  }

  return backendFetch('/register', 'POST', body)
}
