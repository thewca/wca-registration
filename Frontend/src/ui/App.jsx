import React, { useCallback, useState } from 'react'
import { AuthContext } from '../api/helper/context/auth_context'

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
    <AuthContext.Provider value={{ user, setUser }}>
      {children}
    </AuthContext.Provider>
  )
}
