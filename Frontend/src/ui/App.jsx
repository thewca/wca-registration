import {
  QueryClient,
  QueryClientProvider,
  useQuery,
} from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import React from 'react'
import { getPermissions } from '../api/auth/get_permissions'
import { PermissionsContext } from '../api/helper/context/permission_context'
import { UserContext } from '../api/helper/context/user_context'
import getMe from '../api/user/get/get_me'
import LoadingMessage from './messages/loadingMessage'

const queryClient = new QueryClient()
export const USER_KEY = 'user'
export const JWT_KEY = 'jwt'
export default function App({ children }) {
  const { isLoading, data: user } = useQuery({
    queryKey: ['user-me'],
    queryFn: () => getMe(),
  })
  const { isLoading: permissionsLoading, data: permissions } = useQuery({
    queryKey: ['permissions-me'],
    queryFn: () => getPermissions(),
  })
  return (
    <QueryClientProvider client={queryClient}>
      <UserContext.Provider value={{ user }}>
        <PermissionsContext.Provider
          value={{
            permissions,
            canAttendCompetition: () =>
              permissions.can_attend_competitions.scope === '*',
            canAdminCompetition: (id) =>
              permissions.can_administer_competitions.scope === '*' ||
              permissions.can_administer_competitions.scope.includes(id),
          }}
        >
          {isLoading || permissionsLoading ? <LoadingMessage /> : children}
        </PermissionsContext.Provider>
      </UserContext.Provider>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
