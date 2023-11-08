import { useQuery } from '@tanstack/react-query'
import React from 'react'
import { UserContext } from '../../api/helper/context/user_context'
import getMe from '../../api/user/get/get_me'
import LoadingMessage from '../messages/loadingMessage'

// The User key is just for mocks, so it can probably be moved somewhere else
export const USER_KEY = 'user'
export const JWT_KEY = 'jwt'
export default function UserProvider({ children }) {
  const {
    isLoading,
    data: user,
    isError,
  } = useQuery({
    queryKey: ['user-me'],
    queryFn: () => getMe(),
    retry: false,
  })
  return isLoading ? (
    <LoadingMessage />
  ) : // eslint-disable-next-line unicorn/no-nested-ternary
  isError ? (
    <UserContext.Provider value={{ user: null }}>
      {children}
    </UserContext.Provider>
  ) : (
    <UserContext.Provider value={{ user }}>{children}</UserContext.Provider>
  )
}
