import externalServiceFetch from '../../helper/external_service_fetch'
import { myBookmarkedCompetitionsRoute } from '../../helper/routes'
import { getBookmarkedMock } from '../../mocks/bookmarked_mock'

export async function getBookmarkedCompetitions() {
  if (process.env.NODE_ENV === 'production') {
    return externalServiceFetch(myBookmarkedCompetitionsRoute)
  }
  return getBookmarkedMock()
}
