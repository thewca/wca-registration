import backendFetch from '../../helper/backend_fetch'

export default async function deleteRegistration(
  competitorID: string,
  competitionID: string
) {
  const body: DeleteRegistrationBody = {
    competition_id: competitionID,
    competitor_id: competitorID,
  }

  return backendFetch('/register', 'DELETE', body)
}
