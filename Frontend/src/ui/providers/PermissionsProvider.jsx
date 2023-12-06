import { useQuery } from '@tanstack/react-query'
import React, { useContext } from 'react'
import { getPermissions } from '../../api/auth/get_permissions'
import { CompetitionContext } from '../../api/helper/context/competition_context'
import { PermissionsContext } from '../../api/helper/context/permission_context'
import { UserContext } from '../../api/helper/context/user_context'
import LoadingMessage from '../messages/loadingMessage'

export default function PermissionsProvider({ children }) {
  const { user } = useContext(UserContext)
  const loggedIn = user !== null
  const { isLoading, data: permissions } = useQuery({
    queryKey: ['permissions-me'],
    queryFn: () => getPermissions(),
    retry: false,
    // Don't try to get permissions if we are not logged in
    enabled: loggedIn,
  })
  const { competitionInfo } = useContext(CompetitionContext)
  return loggedIn && isLoading ? (
    <LoadingMessage />
  ) : (
    <PermissionsContext.Provider
      value={{
        permissions,
        canAttendCompetition:
          permissions?.can_attend_competitions.scope === '*',
        canAdminCompetition:
          permissions?.can_administer_competitions.scope === '*' ||
          permissions?.can_administer_competitions.scope.includes(
            competitionInfo.id
          ),
        isOrganizerOrDelegate: competitionInfo.organizers
          .concat(competitionInfo.delegates)
          .some((organizer) => organizer.id === user.id),
      }}
    >
      {children}
    </PermissionsContext.Provider>
  )
}
