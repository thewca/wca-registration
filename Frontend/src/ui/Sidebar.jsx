import { Sidebar } from '@thewca/wca-components'
import React from 'react'
import { useParams } from 'react-router-dom'

export default function PageSidebar() {
  const { competition_id } = useParams()
  return (
    <Sidebar
      items={[
        {
          title: 'Registration',
          iconName: 'list ul',
          path: `/${competition_id}/registrations/edit`,
          active: false,
          reactRoute: true,
        },
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
