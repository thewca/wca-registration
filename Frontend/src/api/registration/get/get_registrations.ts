import backendFetch from '../../helper/backend_fetch'

export default async function getRegistrations(competitionID: string) {
  return backendFetch(`/registrations?competition_id=${competitionID}`, 'GET')
}
