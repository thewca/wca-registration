import backendFetch from '../../helper/backend_fetch'

export default async function updateRegistration(
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
