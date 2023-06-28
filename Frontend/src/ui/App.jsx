import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import React, { useCallback, useState } from 'react'
import { AuthContext } from '../api/helper/context/auth_context'

const queryClient = new QueryClient()
export const USER_KEY = 'user'
export const JWT_KEY = 'jwt'
export default function App({ children }) {
  const [user, setUserState] = useState(localStorage.getItem(USER_KEY))
  const setUser = useCallback((user) => {
    localStorage.setItem(USER_KEY, user)
    localStorage.removeItem(JWT_KEY)
    setUserState(user)
  }, [])
  return (
    <QueryClientProvider client={queryClient}>
      <AuthContext.Provider value={{ user, setUser }}>
        {children}
      </AuthContext.Provider>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
