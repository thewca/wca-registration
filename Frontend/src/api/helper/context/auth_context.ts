import { createContext } from 'react'

interface AuthContext {
  user: string | null
  setUser: (user: string | null) => void
}

export const AuthContext = createContext<AuthContext>({
  user: null,
  setUser: () => {},
})
