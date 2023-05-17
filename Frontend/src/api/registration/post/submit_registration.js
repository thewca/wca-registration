import backendFetch from '../../helper/backend_fetch'

export default async function submitEventRegistration(
  competitorId,
  competitionId,
  events
) {
  const formData = new FormData()
  formData.append('competitor_id', competitorId)
  formData.append('competition_id', competitionId)
  events.forEach((eventId) => formData.append('event_ids[]', eventId))

  return backendFetch('/register', 'POST', formData)
}
