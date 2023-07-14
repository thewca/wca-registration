import externalServiceFetch from '../helper/external_service_fetch'
import getPermissionsMock from '../mocks/get_permissions'

interface Permissions {
  can_attend_competitions: { scope: Scope }
  can_organize_competitions: { scope: Scope }
  can_administer_competitions: { scope: Scope }
}
type Scope = '*' | string[]

function getPermissions() {
  if (process.env.NODE_ENV === 'production') {
    return externalServiceFetch(
      'https://test-registration.worldcubeassociation.org/api/v10/users/me/permissions'
    ) as Permissions
  }
  return getPermissionsMock()
}

export function canAdminCompetition(competitionId: string) {
  const permissions = getPermissions()
  return (
    permissions.can_administer_competitions.scope === '*' ||
    permissions.can_administer_competitions.scope.includes(competitionId)
  )
}

export function canAttendCompetitions() {
  const permissions = getPermissions()
  return permissions.can_attend_competitions.scope === '*'
}

// TODO: move these to I18n
export const CAN_ADMINISTER_COMPETITIONS = 'Can Administer Competitions'
export const CAN_ATTEND_COMPETITIONS = 'Can attend Competitions'
