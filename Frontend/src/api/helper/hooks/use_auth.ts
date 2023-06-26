import { useEffect } from 'react'
import { UserType } from '../../types'
import useLocalStorage from './use_local_storage'
import { useUser } from './use_user'

export function useAuth() {
  const { user, addUser, removeUser } = useUser()
  const { getItem } = useLocalStorage()

  useEffect(() => {
    const user = getItem('user')
    if (user) {
      addUser(JSON.parse(user))
    }
  }, [addUser, getItem])

  const login = (user: UserType) => {
    addUser(user)
  }

  const logout = () => {
    removeUser()
  }

  return { user, login, logout }
}
