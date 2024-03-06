import { UserFull } from '../api/helper/context/user_context'

interface RegistrationPermissionMessageParams {
  loggedIn: boolean
  userInfo: UserFull
}
export function registrationPermissionMessage({
  loggedIn,
  userInfo,
}: RegistrationPermissionMessageParams): string {
  if (!loggedIn) {
    return 'api.login_message'
  }
  if (!userInfo.name) {
    return 'registrations.errors.need_name'
  }
  // gender missing
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  if (!userInfo.gender) {
    return 'registrations.errors.need_gender'
  }
  if (!userInfo.country_iso2) {
    return 'registrations.errors.need_country'
  }
  // Missing check: No dob
  return ''
}
