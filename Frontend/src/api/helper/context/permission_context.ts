import { createContext } from 'react'
import { Permissions } from '../../auth/get_permissions'

interface PermissionsContext {
  permissions?: Permissions
  canAdminCompetition: (id: string) => boolean
  canAttendCompetition: () => boolean
}

export const PermissionsContext = createContext<PermissionsContext>({
  permissions: undefined,
  canAdminCompetition: (_) => false,
  canAttendCompetition: () => false,
})
