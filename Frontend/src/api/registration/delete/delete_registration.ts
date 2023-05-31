import backendFetch from '../../helper/backend_fetch'
import { DeleteRegistrationBody } from '../../types'

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
