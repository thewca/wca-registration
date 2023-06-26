import { useContext } from 'react'
import { UserType } from '../../types'
import { AuthContext } from '../context/auth_context'
import useLocalStorage from './use_local_storage'

export const USER_KEY = 'user'

export function useUser() {
  const { user, setUser } = useContext(AuthContext)
  const { setItem } = useLocalStorage()

  const addUser = (user: UserType) => {
    setUser(user)
    setItem(USER_KEY, JSON.stringify(user))
  }

  const removeUser = () => {
    setUser(null)
    setItem(USER_KEY, '')
  }

  return { user, addUser, removeUser }
}
