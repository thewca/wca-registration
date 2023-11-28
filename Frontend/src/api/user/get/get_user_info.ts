import externalServiceFetch from '../../helper/external_service_fetch'
import { userInfoRoute, usersInfoRoute } from '../../helper/routes'

export interface User {
  id: number
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

export async function getCompetitorInfo(userId: string): Promise<UserInfo> {
  return externalServiceFetch(userInfoRoute(userId))
}

export async function getCompetitorsInfo(
  userIds: string[]
): Promise<{ users: User[] }> {
  return externalServiceFetch(usersInfoRoute(userIds))
}
