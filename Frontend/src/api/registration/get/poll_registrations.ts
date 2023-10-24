import externalServiceFetch from '../../helper/external_service_fetch'
import { pollingRoute } from '../../helper/routes'
import pollingMock from '../../mocks/polling_mock'

export interface RegistrationStatus {
  status: {
    competing: string
    payment?: string
  }
  queue_count: number
}

export async function pollRegistrations(
  userId: string,
  competitionId: string
): Promise<RegistrationStatus> {
  if (process.env.NODE_ENV === 'production') {
    return externalServiceFetch(pollingRoute(userId, competitionId))
  }
  return pollingMock()
}
