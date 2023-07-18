import externalServiceFetch from '../helper/external_service_fetch'
import getPermissionsMock from '../mocks/get_permissions'

export interface Permissions {
  can_attend_competitions: { scope: Scope; reasons?: number }
  can_organize_competitions: { scope: Scope }
  can_administer_competitions: { scope: Scope }
}
type Scope = '*' | string[]

export async function getPermissions(): Promise<Permissions> {
  if (process.env.NODE_ENV === 'production') {
    return externalServiceFetch(
      'https://test-registration.worldcubeassociation.org/api/v10/users/me/permissions'
    )
  }
  return getPermissionsMock()
}

// TODO: move these to I18n
export const CAN_ADMINISTER_COMPETITIONS = 'Can Administer Competitions'
export const CAN_ATTEND_COMPETITIONS = 'Can attend Competitions'
