import { Schedule } from '@wca/helpers'
import externalServiceFetch from '../../helper/external_service_fetch'

export default async function getSchedule(
  competitionId: string
): Promise<Schedule> {
  return externalServiceFetch(
    `https://test-registration.worldcubeassociation.org/api/v10/competitions/${competitionId}/schedule`
  )
}
