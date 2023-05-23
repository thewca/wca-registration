import backendFetch from '../../helper/backend_fetch'

export default async function getRegistrations(competitionID) {
  return backendFetch(`/registrations?competition_id=${competitionID}`, 'GET')
}
