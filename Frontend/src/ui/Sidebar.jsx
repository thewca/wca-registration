import { Sidebar } from '@thewca/wca-components'
import React, { useContext } from 'react'
import { useParams } from 'react-router-dom'
import { canAdminCompetition } from '../api/auth/get_permissions'
import { AuthContext } from '../api/helper/context/auth_context'

export default function PageSidebar() {
  const { competition_id } = useParams()
  const { user } = useContext(AuthContext)
  const sideBarItems = []
  if (canAdminCompetition(user, competition_id)) {
    sideBarItems.push({
      title: 'Registration',
      iconName: 'list ul',
      path: `/${competition_id}/registrations/edit`,
      active: false,
      reactRoute: true,
    })
  }
  return (
    <Sidebar
      items={[
        ...sideBarItems,
        {
          title: 'Register',
          iconName: 'sign in alt',
          path: `/${competition_id}/register`,
          active: false,
          reactRoute: true,
        },
        {
          title: 'Competitors',
          iconName: 'users',
          path: `/${competition_id}/registrations`,
          active: false,
          reactRoute: true,
        },
      ]}
    />
  )
}
