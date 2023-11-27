import { useQuery } from '@tanstack/react-query'
import React from 'react'
import { getJWT } from '../../api/auth/get_jwt'
import { UserContext } from '../../api/helper/context/user_context'
import getMe from '../../api/user/get/get_me'
import LoadingMessage from '../messages/loadingMessage'

// The User key is just for mocks, so it can probably be moved somewhere else
export const USER_KEY = 'user'
export const JWT_KEY = 'jwt'
export default function UserProvider({ children }) {
  const { isLoading, data: user } = useQuery({
    queryKey: ['user-me'],
    queryFn: () => getMe(),
    retry: false,
    onError: (_) => {
      // We are not logged in, set user explicitly to undefined?
    },
    onSuccess: (_) => {
      // Get a new token so when a user switches account it overwrites the token
      getJWT(true)
    },
  })
  return isLoading ? (
    <LoadingMessage />
  ) : (
    <UserContext.Provider value={{ user }}>{children}</UserContext.Provider>
  )
}
