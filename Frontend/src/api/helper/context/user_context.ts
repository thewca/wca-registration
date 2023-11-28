import { createContext } from 'react'

export interface UserFull {
  id: number
  created_at: string
  updated_at: string
  name: string
  delegate_status: string
  gender: 'm' | 'f' | 'o'
  country_iso2: string
  email: string
  region: string
  senior_delegate_id: number
  class: string
  //TODO
  teams: object[]
  wca_id: string
  country: {
    id: string
    name: string
    iso2: string
  }
  avatar: {
    url: string
    pending_url: string
    thumb_url: string
  }
}
interface UserContext {
  user: UserFull | null
}

export const UserContext = createContext<UserContext>({
  user: null,
})
