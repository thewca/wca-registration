import { createContext } from 'react'
import { components } from '../../schema'

interface RegistrationContext {
  registration: components['schemas']['registrationAdmin'] | null
  refetch: () => void
  isRegistered: boolean
}

export const RegistrationContext = createContext<RegistrationContext>({
  registration: null,
  refetch: () => {},
  isRegistered: false,
})
