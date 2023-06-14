import backendFetch from '../../helper/backend_fetch'

export async function getConfirmedRegistrations(competitionID: string) {
  return backendFetch(`/registrations?competition_id=${competitionID}`, 'GET')
}

export async function getAllRegistrations(competitionID: string) {
  return backendFetch(
    `/registrations/admin?competition_id=${competitionID}`,
    'GET'
  )
}
