import { UserFull } from '../../helper/context/user_context'
import externalServiceFetch from '../../helper/external_service_fetch'
import getMeMock from '../../mocks/get_me'

export default async function getMe(): Promise<UserFull | null> {
  if (process.env.NODE_ENV === 'production') {
    const userRequest = await externalServiceFetch(
      `https://test-registration.worldcubeassociation.org/api/v10/users/me`
    )
    return userRequest.user
  }
  return getMeMock()
}
