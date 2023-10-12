import { UserFull } from '../../helper/context/user_context'
import externalServiceFetch from '../../helper/external_service_fetch'
import { meRoute } from '../../helper/routes'
import getMeMock from '../../mocks/get_me'

export default async function getMe(): Promise<UserFull | null> {
  if (process.env.NODE_ENV === 'production') {
    const userRequest = await externalServiceFetch(meRoute)
    return userRequest.user
  }
  return getMeMock()
}
