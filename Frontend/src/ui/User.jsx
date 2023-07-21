import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { getPermissions } from '../api/auth/get_permissions'
import { PermissionsContext } from '../api/helper/context/permission_context'
import { UserContext } from '../api/helper/context/user_context'
import getMe from '../api/user/get/get_me'
import LoadingMessage from './messages/loadingMessage'
import { CompetitionContext } from '../api/helper/context/competition_context'

export const USER_KEY = 'user'
export const JWT_KEY = 'jwt'
export default function User({ children }) {
  const { isLoading, data: user } = useQuery({
    queryKey: ['user-me'],
    queryFn: () => getMe(),
  })
  const { isLoading: permissionsLoading, data: permissions } = useQuery({
    queryKey: ['permissions-me'],
    queryFn: () => getPermissions(),
  })
  const { competitionInfo } = useContext(CompetitionContext)
  return isLoading || permissionsLoading ? (
    <LoadingMessage />
  ) : (
    <UserContext.Provider value={{ user }}>
      <PermissionsContext.Provider
        value={{
          permissions,
          canAttendCompetition:
            permissions.can_attend_competitions.scope === '*',
          canAdminCompetition:
            permissions.can_administer_competitions.scope === '*' ||
            permissions.can_administer_competitions.scope.includes(
              competitionInfo.id
            ),
        }}
      >
        {children}
      </PermissionsContext.Provider>
    </UserContext.Provider>
  )
}
