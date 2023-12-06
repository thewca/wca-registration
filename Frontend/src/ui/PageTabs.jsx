import { CubingIcon, UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Dropdown, Menu } from 'semantic-ui-react'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { PermissionsContext } from '../api/helper/context/permission_context'
import { BASE_ROUTE } from '../routes'

function pathMatch(name, pathname) {
  const registerExpression = /\/competitions\/v2\/[a-zA-Z0-9]+\/register/
  const registrationsExpression =
    /\/competitions\/v2\/[a-zA-Z0-9]+\/registrations\/edit/
  const competitorsExpression =
    /\/competitions\/v2\/[a-zA-Z0-9]+\/registrations\/?$/
  const eventsExpressions = /\/competitions\/v2\/[a-zA-Z0-9]+\/events/
  const scheduleExpressions = /\/competitions\/v2\/[a-zA-Z0-9]+\/schedule/
  const infoExpression = /\/competitions\/v2\/[a-zA-Z0-9]+\/?$/
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
    case 'events':
      return eventsExpressions.test(pathname)
    default: {
      // We are in a custom tab
      return name === Number.parseInt(pathname.split('/tabs/')[1], 10)
    }
  }
}

export default function PageTabs() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAdminCompetition } = useContext(PermissionsContext)

  const navigate = useNavigate()
  const location = useLocation()

  const menuItems = useMemo(() => {
    const optionalTabs = []

    if (competitionInfo.use_wca_registration) {
      optionalTabs.push({
        key: 'register',
        icon: 'sign in alt',
        label: 'Register',
      })
    }
    if (canAdminCompetition) {
      optionalTabs.push({
        key: 'registrations',
        route: 'registrations/edit',
        icon: 'list ul',
        label: 'Registrations',
      })
    }
    if (new Date(competitionInfo.registration_open) < Date.now()) {
      optionalTabs.push({
        key: 'competitors',
        route: 'registrations',
        icon: 'users',
        label: 'Competitors',
      })
    }

    return [
      {
        key: 'info',
        route: '',
        icon: 'info',
        label: 'General Info',
      },
      ...optionalTabs,
      {
        key: 'events',
        icon: competitionInfo.main_event_id ?? competitionInfo.event_ids[0],
        label: 'Events',
        cubing: true,
      },
      {
        key: 'schedule',
        icon: 'calendar',
        label: 'Schedule',
      },
    ]
  }, [
    competitionInfo.use_wca_registration,
    competitionInfo.registration_open,
    competitionInfo.main_event_id,
    competitionInfo.event_ids,
    canAdminCompetition,
  ])

  const customTabActive = useMemo(() => {
    return competitionInfo.tabs.some((competitionTab) =>
      pathMatch(competitionTab.id, location.pathname)
    )
  }, [competitionInfo.tabs, location])

  return (
    <Menu attached fluid widths={menuItems.length + 1} size="huge" stackable>
      {menuItems.map((menuConfig) => (
        <Menu.Item
          key={menuConfig.key}
          name={menuConfig.key}
          onClick={() =>
            navigate(
              `${BASE_ROUTE}/${competitionInfo.id}/${
                menuConfig.route ?? menuConfig.key
              }`
            )
          }
          active={pathMatch(menuConfig.key, location.pathname)}
        >
          {menuConfig.cubing && <CubingIcon event={menuConfig.icon} selected />}
          {menuConfig.icon && !menuConfig.cubing && (
            <UiIcon name={menuConfig.icon} />
          )}
          {menuConfig.label}
        </Menu.Item>
      ))}
      <Dropdown item text="More" className={customTabActive ? 'active' : ''}>
        <Dropdown.Menu>
          {competitionInfo.tabs.map((competitionTab) => (
            <Dropdown.Item
              key={competitionTab.id}
              onClick={() =>
                navigate(
                  `${BASE_ROUTE}/${competitionInfo.id}/tabs/${competitionTab.id}`
                )
              }
              active={pathMatch(competitionTab.id, location.pathname)}
            >
              {competitionTab.name}
            </Dropdown.Item>
          ))}
        </Dropdown.Menu>
      </Dropdown>
    </Menu>
  )
}
