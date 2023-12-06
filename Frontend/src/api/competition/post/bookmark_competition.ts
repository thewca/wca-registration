import externalServiceFetch from '../../helper/external_service_fetch'
import { getCSRFToken } from '../../helper/get_csrf_token'
import {
  bookmarkCompetitionRoute,
  unbookmarkCompetitionRoute,
} from '../../helper/routes'
import {
  addBookmarkedMock,
  removeBookmarkedMock,
} from '../../mocks/bookmarked_mock'

export async function bookmarkCompetition(
  competitionId: string
): Promise<boolean> {
  if (process.env.NODE_ENV === 'production') {
    return externalServiceFetch(bookmarkCompetitionRoute, {
      method: 'POST',
      body: JSON.stringify({ id: competitionId }),
      headers: {
        'X-CSRF-Token': getCSRFToken(),
        'Content-Type': 'application/json',
      },
    })
  }
  return addBookmarkedMock(competitionId)
}

export async function unbookmarkCompetition(
  competitionId: string
): Promise<boolean> {
  if (process.env.NODE_ENV === 'production') {
    return externalServiceFetch(unbookmarkCompetitionRoute, {
      method: 'POST',
      body: JSON.stringify({ id: competitionId }),
      headers: {
        'X-CSRF-Token': getCSRFToken(),
        'Content-Type': 'application/json',
      },
    })
  }
  return removeBookmarkedMock(competitionId)
}
