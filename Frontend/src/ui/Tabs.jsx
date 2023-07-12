import { UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { Menu, Tab } from 'semantic-ui-react'
import { canAdminCompetition } from '../api/auth/get_permissions'
import { AuthContext } from '../api/helper/context/auth_context'
import { CompetitionContext } from '../api/helper/context/competition_context'
import styles from './tabs.module.scss'

export default function PageTabs() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { user } = useContext(AuthContext)
  const navigate = useNavigate()
  const panes = useMemo(() => {
    const adminPanes = []
    if (canAdminCompetition(competitionInfo.id)) {
      adminPanes.push({
        menuItem: (
          <Menu.Item
            key="tab-registration"
            className={styles.tabItem}
            onClick={() =>
              navigate(`/competitions/${competitionInfo.id}/registrations/edit`)
            }
          >
            <UiIcon name="list ul" />
            Registrations
          </Menu.Item>
        ),
        render: () => {},
      })
    }
    return [
      {
        menuItem: (
          <Menu.Item
            key="tab-info"
            className={styles.tabItem}
            onClick={() => navigate(`/competitions/${competitionInfo.id}`)}
          >
            <UiIcon name="info" />
            General Info
          </Menu.Item>
        ),
        render: () => {},
      },
      ...adminPanes,
      {
        menuItem: (
          <Menu.Item
            key="tab-Competitors"
            className={styles.tabItem}
            onClick={() =>
              navigate(`/competitions/${competitionInfo.id}/registrations`)
            }
          >
            <UiIcon name="users" />
            Competitors
          </Menu.Item>
        ),
        render: () => {},
      },
      {
        menuItem: (
          <Menu.Item
            key="tab-register"
            className={styles.tabItem}
            onClick={() =>
              navigate(`/competitions/${competitionInfo.id}/register`)
            }
          >
            <UiIcon name="sign in alt" />
            Register
          </Menu.Item>
        ),
        render: () => {},
      },
    ]
  }, [competitionInfo.id, navigate, user])
  return (
    <Tab
      panes={panes}
      renderActiveOnly={true}
      menu={{ secondary: true, pointing: true }}
      defaultActiveIndex={0} //TODO figure out how to set this correctly based on the route
    />
  )
}
