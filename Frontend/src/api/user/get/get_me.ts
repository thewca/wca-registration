import { UserFull } from '../../helper/context/user_context'
import externalServiceFetch from '../../helper/external_service_fetch'
import getMeMock from '../../mocks/get_me'

export default async function getMe(): Promise<UserFull> {
  if (process.env.NODE_ENV === 'production') {
    // TODO Correctly identify when the user is not logged in (haven't written this API Route on the monolith yet)
    return externalServiceFetch(
      `https://test-registration.worldcubeassociation.org/api/v10/users/me`
    )
  }
  return getMeMock()
}
