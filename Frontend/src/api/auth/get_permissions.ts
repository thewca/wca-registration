import externalServiceFetch from '../helper/external_service_fetch'
import { permissionsRoute } from '../helper/routes'
import getPermissionsMock from '../mocks/get_permissions'

export interface Permissions {
  can_attend_competitions: { scope: Scope; until?: string }
  can_organize_competitions: { scope: Scope }
  can_administer_competitions: { scope: Scope }
}
type Scope = '*' | string[]

export async function getPermissions(): Promise<Permissions> {
  if (process.env.NODE_ENV === 'production') {
    return externalServiceFetch(permissionsRoute)
  }
  return getPermissionsMock()
}
