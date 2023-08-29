// import externalServiceFetch from '../../helper/external_service_fetch'
import pollingMock from '../../mocks/polling_mock'

export interface RegistrationStatus {
  status: {
    competing: string
    payment?: string
  }
  queue_count: number
}

export async function pollRegistrations(): Promise<RegistrationStatus> {
  if (process.env.NODE_ENV === 'production') {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore inject at build time
    return externalServiceFetch(process.env.POLL_URL)
  }
  return pollingMock()
}
