import backendFetch from '../../helper/backend_fetch'
import { components } from '../../schema'

export async function getWaitingCompetitors(
  competitionId: string
): Promise<components['schemas']['registration'][]> {
  return backendFetch(`/registrations/${competitionId}/waiting`, 'GET', {
    needsAuthentication: false,
  }) as Promise<
    components['schemas']['registration'][]
  >
}
