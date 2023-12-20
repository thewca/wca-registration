import { EventId } from '@wca/helpers'
import externalServiceFetch from '../../helper/external_service_fetch'
import { preferredEventsRoute } from '../../helper/routes'
import { getPreferredEventsMock } from '../../mocks/get_preferred_events'

export default async function getPreferredEvents(): Promise<EventId[]> {
  if (process.env.NODE_ENV === 'production') {
    return externalServiceFetch(preferredEventsRoute)
  }
  // returns a random selection of events as a mock
  return getPreferredEventsMock()
}
