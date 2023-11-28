import { CubingIcon, UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Menu, Tab } from 'semantic-ui-react'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { PermissionsContext } from '../api/helper/context/permission_context'
import { BASE_ROUTE } from '../routes'
import styles from './tabs.module.scss'

function pathMatch(name, pathname) {
  const registerExpression = /\/competitions\/v2\/[a-zA-Z0-9]+\/register/
  const registrationsExpression =
    /\/competitions\/v2\/[a-zA-Z0-9]+\/registrations\/edit/
  const competitorsExpression =
    /\/competitions\/v2\/[a-zA-Z0-9]+\/registrations/
  const eventsExpressions = /\/competitions\/v2\/[a-zA-Z0-9]+\/events/
  const scheduleExpressions = /\/competitions\/v2\/[a-zA-Z0-9]+\/schedule/
  const infoExpression = /\/competitions\/v2\/[a-zA-Z0-9]+$/
  const waitingExpression = /\/competitions\/v2\/[a-zA-Z0-9]+\/waiting/
  switch (name) {
    case 'register':
      return registerExpression.test(pathname)
    case 'registrations':
      return registrationsExpression.test(pathname)
    case 'competitors':
      return competitorsExpression.test(pathname)
    case 'schedule':
      return scheduleExpressions.test(pathname)
    case 'info':
      return infoExpression.test(pathname)
    case 'waiting':
      return waitingExpression.test(pathname)
    case 'events':
      return eventsExpressions.test(pathname)
    default: {
      // We are in a custom tab
      const tabId = name.slice(5)
      return tabId === pathname.split('/tabs/')[1]
    }
  }
}

export default function PageTabs() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAdminCompetition } = useContext(PermissionsContext)
  const navigate = useNavigate()
  const location = useLocation()
  const panes = useMemo(() => {
    const optionalTabs = []
    if (competitionInfo.use_wca_registration) {
      optionalTabs.push({
        menuItem: (
          <Menu.Item
            key="tab-register"
            name="register"
            className={styles.tabItem}
            onClick={() =>
              navigate(`${BASE_ROUTE}/${competitionInfo.id}/register`)
            }
          >
            <UiIcon name="sign in alt" />
            Register
          </Menu.Item>
        ),
        render: () => {},
      })
    }
    if (canAdminCompetition) {
      optionalTabs.push({
        menuItem: (
          <Menu.Item
            key="tab-registrations"
            name="registrations"
            className={styles.tabItem}
            onClick={() =>
              navigate(`${BASE_ROUTE}/${competitionInfo.id}/registrations/edit`)
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
            name="competitors"
            className={styles.tabItem}
            onClick={() =>
              navigate(`${BASE_ROUTE}/${competitionInfo.id}/registrations`)
            }
          >
            <UiIcon name="users" />
            Competitors
          </Menu.Item>
        ),
        render: () => {},
      })
      optionalTabs.push({
        menuItem: (
          <Menu.Item
            key="tab-Waiting"
            name="waiting"
            className={styles.tabItem}
            onClick={() =>
              navigate(`${BASE_ROUTE}/${competitionInfo.id}/waiting`)
            }
          >
            <UiIcon name="clock" />
            Waiting List
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
            name="info"
            className={styles.tabItem}
            onClick={() => navigate(`${BASE_ROUTE}/${competitionInfo.id}`)}
          >
            <UiIcon name="info" />
            General Info
          </Menu.Item>
        ),
        render: () => {},
      },
      ...optionalTabs,
      {
        menuItem: (
          <Menu.Item
            key="tab-events"
            name="events"
            className={styles.tabItem}
            onClick={() =>
              navigate(`${BASE_ROUTE}/${competitionInfo.id}/events`)
            }
          >
            <CubingIcon
              event={
                competitionInfo.main_event_id ?? competitionInfo.event_ids[0]
              }
              selected
            />
            Events
          </Menu.Item>
        ),
        render: () => {},
      },
      {
        menuItem: (
          <Menu.Item
            key="tab-schedule"
            name="schedule"
            className={styles.tabItem}
            onClick={() =>
              navigate(`${BASE_ROUTE}/${competitionInfo.id}/schedule`)
            }
          >
            <UiIcon name="calendar" />
            Schedule
          </Menu.Item>
        ),
        render: () => {},
      },
      ...competitionInfo.tabs.map((tab) => {
        return {
          menuItem: (
            <Menu.Item
              key={`tabs-${tab.id}`}
              name={`tabs-${tab.id}`}
              className={styles.tabItem}
              onClick={() =>
                navigate(`${BASE_ROUTE}/${competitionInfo.id}/tabs/${tab.id}`)
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
    competitionInfo.use_wca_registration,
    competitionInfo.registration_open,
    competitionInfo.main_event_id,
    competitionInfo.event_ids,
    competitionInfo.tabs,
    competitionInfo.id,
    canAdminCompetition,
    navigate,
  ])

  return (
    <Tab
      className={styles.tabs}
      panes={panes}
      renderActiveOnly={true}
      menu={{ secondary: true, pointing: true }}
      // This is only relevant on refresh, why we don't need to use useEffect
      defaultActiveIndex={
        panes.findIndex((pane) => {
          return pathMatch(pane.menuItem.props.name, location.pathname)
        }) ?? 0
      }
    />
  )
}
