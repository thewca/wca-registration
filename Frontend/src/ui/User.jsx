import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { getPermissions } from '../api/auth/get_permissions'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { PermissionsContext } from '../api/helper/context/permission_context'
import { UserContext } from '../api/helper/context/user_context'
import getMe from '../api/user/get/get_me'
import { setMessage } from './events/messages'
import LoadingMessage from './messages/loadingMessage'

export const USER_KEY = 'user'
export const JWT_KEY = 'jwt'
export default function User({ children }) {
  const { isLoading, data: user } = useQuery({
    queryKey: ['user-me'],
    queryFn: () => getMe(),
    retry: false,
    onError: (_) => {
      // We are not logged in, set user explicitly to undefined?
    },
  })
  const { isLoading: permissionsLoading, data: permissions } = useQuery({
    queryKey: ['permissions-me'],
    queryFn: () => getPermissions(),
    retry: false,
    onError: (err) => {
      setMessage(err.message, 'error')
    },
    // Don't try to get permissions if we are not logged in
    enabled: user.id,
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
