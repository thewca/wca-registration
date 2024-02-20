import { components } from '../api/schema'

export function addUserData<Type extends { user_id: number }>(
  registrations: Type[],
  userInfo: components['schemas']['userInfo'][],
): (Type & { user?: components['schemas']['userInfo'] })[] {
  return registrations.map((r) => {
    const user = userInfo.find((u) => u.id === r.user_id)
    return user ? { ...r, user } : r
  })
}
