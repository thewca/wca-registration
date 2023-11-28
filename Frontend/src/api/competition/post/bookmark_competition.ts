import externalServiceFetch from '../../helper/external_service_fetch'
import { getCSRFToken } from '../../helper/get_csrf_token'
import {
  bookmarkCompetitionRoute,
  unbookmarkCompetitionRoute,
} from '../../helper/routes'

export async function bookmarkCompetition(
  competitionId: string
): Promise<boolean> {
  return externalServiceFetch(bookmarkCompetitionRoute, {
    method: 'POST',
    body: JSON.stringify({ id: competitionId }),
    headers: {
      'X-CSRF-Token': getCSRFToken(),
      'Content-Type': 'application/json',
    },
  })
}

export async function unbookmarkCompetition(
  competitionId: string
): Promise<boolean> {
  return externalServiceFetch(unbookmarkCompetitionRoute, {
    method: 'POST',
    body: JSON.stringify({ id: competitionId }),
    headers: {
      'X-CSRF-Token': getCSRFToken(),
      'Content-Type': 'application/json',
    },
  })
}
