import { Sidebar } from '@thewca/wca-components'
import React, { useContext, useMemo } from 'react'
import { canAdminCompetition } from '../api/auth/get_permissions'
import { AuthContext } from '../api/helper/context/auth_context'
import { CompetitionContext } from '../api/helper/context/competition_context'

export default function PageSidebar() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { user } = useContext(AuthContext)
  const sideBarItems = useMemo(() => {
    const adminItems = []
    // TODO: When we have finalised the design, it probably will make sense to move this to a child component like:
    // {canAdmin... && <SidebarItem title={...} iconName={...} ... />} // registration
    if (canAdminCompetition(user, competitionInfo.id)) {
      adminItems.push({
        title: 'Registration',
        iconName: 'list ul',
        path: `/${competitionInfo.id}/registrations/edit`,
        active: false,
        reactRoute: true,
      })
    }
    return [
      ...adminItems,
      {
        title: 'Register',
        iconName: 'sign in alt',
        path: `/${competitionInfo.id}/register`,
        active: false,
        reactRoute: true,
      },
      {
        title: 'Competitors',
        iconName: 'users',
        path: `/${competitionInfo.id}/registrations`,
        active: false,
        reactRoute: true,
      },
    ]
  }, [user, competitionInfo.id])
  return <Sidebar items={sideBarItems} />
}
