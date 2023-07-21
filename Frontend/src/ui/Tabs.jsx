import { UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { Menu, Tab } from 'semantic-ui-react'
import { CompetitionContext } from '../api/helper/context/competition_context'
import styles from './tabs.module.scss'
import { PermissionsContext } from '../api/helper/context/permission_context'

export default function PageTabs() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAdminCompetition } = useContext(PermissionsContext)
  const navigate = useNavigate()
  const panes = useMemo(() => {
    const optionalTabs = []
    if (competitionInfo.use_wca_registration) {
      optionalTabs.push({
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
      })
    }
    if (canAdminCompetition(competitionInfo.id)) {
      optionalTabs.push({
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
    if (new Date(competitionInfo.registration_open) < Date.now()) {
      optionalTabs.push({
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
      ...optionalTabs,
      ...competitionInfo.tabs.map((tab) => {
        return {
          menuItem: (
            <Menu.Item
              key={`tabs-${tab.id}`}
              className={styles.tabItem}
              onClick={() =>
                navigate(`/competitions/${competitionInfo.id}/tabs/${tab.id}`)
              }
            >
              {tab.name}
            </Menu.Item>
          ),
          render: () => {},
        }
      }),
    ]
  }, [
    canAdminCompetition,
    competitionInfo.id,
    competitionInfo.use_wca_registration,
    competitionInfo.registration_open,
    competitionInfo.tabs,
    navigate,
  ])
  return (
    <Tab
      panes={panes}
      renderActiveOnly={true}
      menu={{ secondary: true, pointing: true }}
      defaultActiveIndex={0} //TODO figure out how to set this correctly based on the route
    />
  )
}
