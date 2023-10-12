import externalServiceFetch from '../../helper/external_service_fetch'
import { userInfoRoute } from '../../helper/routes'

export interface User {
  id: string
  wca_id: string
  name: string
  country: {
    id: string
    name: string
    iso2: string
  }
}

export interface UserInfo {
  user: User
}

export default async function getCompetitorInfo(
  userId: string
): Promise<UserInfo> {
  return externalServiceFetch(userInfoRoute(userId))
}
