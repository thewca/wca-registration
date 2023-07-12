import externalServiceFetch from '../helper/external_service_fetch'

interface Permissions {
  can_attend_competitions: { scope: Scope }
  can_organize_competitions: { scope: Scope }
  can_administer_competitions: { scope: Scope }
}
type Scope = '*' | string[]

async function getPermissions() {
  return externalServiceFetch(
    'https://test-registration.worldcubeassociation.org/api/v10/users/me/permissions'
  ) as Promise<Permissions>
}

export async function canAdminCompetition(competitionId: string) {
  const permissions = await getPermissions()
  return (
    permissions.can_administer_competitions.scope === '*' ||
    permissions.can_administer_competitions.scope.includes(competitionId)
  )
}

export async function canAttendCompetitions() {
  const permissions = await getPermissions()
  return permissions.can_attend_competitions.scope === '*'
}

// TODO: move these to I18n
export const CAN_ADMINISTER_COMPETITIONS = 'Can Administer Competitions'
export const CAN_ATTEND_COMPETITIONS = 'Can attend Competitions'
