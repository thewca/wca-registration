import { CubingIcon, UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Menu } from 'semantic-ui-react'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { PermissionsContext } from '../api/helper/context/permission_context'
import { hasPassed } from '../lib/dates'
import { BASE_ROUTE } from '../routes'

const adminMenu = [registrationsMenuConfig, waitingMenuConfig]

export default function PageTabs() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAdminCompetition } = useContext(PermissionsContext)

  const navigate = useNavigate()
  const location = useLocation()

  const competitorMenu = useMemo(() => {
    const optionalTabs = []

    if (competitionInfo.use_wca_registration) {
      optionalTabs.push(registerMenuConfig)
    }
    if (hasPassed(competitionInfo.registration_open)) {
      optionalTabs.push(competitorsMenuConfig)
    }

    const eventTabIcon =
      competitionInfo.main_event_id ?? competitionInfo.event_ids[0]

    return [
      generalInfoMenuConfig,
      ...optionalTabs,
      eventsMenuConfig(eventTabIcon),
      scheduleMenuConfig,
    ]
  }, [
    competitionInfo.use_wca_registration,
    competitionInfo.registration_open,
    competitionInfo.main_event_id,
    competitionInfo.event_ids,
  ])

  const hasCustomTabs = competitionInfo.tabs.length > 0

  return (
    <>
      <Menu attached fluid widths={competitorMenu.length} size="huge" stackable>
        {competitorMenu.map((menuConfig) => (
          <Menu.Item
            key={menuConfig.key}
            name={menuConfig.key}
            onClick={() =>
              navigate(
                `${BASE_ROUTE}/${competitionInfo.id}/${
                  menuConfig.route ?? menuConfig.key
                }`,
              )
            }
            active={pathMatch(menuConfig.key, location.pathname)}
          >
            {menuConfig.cubing && (
              <CubingIcon event={menuConfig.icon} selected />
            )}
            {menuConfig.icon && !menuConfig.cubing && (
              <UiIcon size="1x" name={menuConfig.icon} />
            )}
            {menuConfig.label}
          </Menu.Item>
        ))}
      </Menu>
      {hasCustomTabs && (
        <Menu
          attached
          fluid
          widths={competitionInfo.tabs.length}
          size="large"
          stackable
        >
          {competitionInfo.tabs.map((competitionTab) => (
            <Menu.Item
              key={competitionTab.id}
              onClick={() =>
                navigate(
                  `${BASE_ROUTE}/${competitionInfo.id}/tabs/${competitionTab.id}`,
                )
              }
              active={pathMatch(competitionTab.id, location.pathname)}
            >
              {competitionTab.name}
            </Menu.Item>
          ))}
        </Menu>
      )}
      {canAdminCompetition && (
        <Menu attached fluid widths={adminMenu.length} size="huge" stackable>
          {adminMenu.map((menuConfig) => (
            <Menu.Item
              key={menuConfig.key}
              name={menuConfig.key}
              onClick={() =>
                navigate(
                  `${BASE_ROUTE}/${competitionInfo.id}/${
                    menuConfig.route ?? menuConfig.key
                  }`,
                )
              }
              active={pathMatch(menuConfig.key, location.pathname)}
            >
              {menuConfig.cubing && (
                <CubingIcon event={menuConfig.icon} selected />
              )}
              {menuConfig.icon && !menuConfig.cubing && (
                <UiIcon size="1x" name={menuConfig.icon} />
              )}
              {menuConfig.label}
            </Menu.Item>
          ))}
        </Menu>
      )}
    </>
  )
}

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

const registerMenuConfig = {
  key: 'register',
  icon: 'sign in alt',
  label: 'Register',
}
const registrationsMenuConfig = {
  key: 'registrations',
  route: 'registrations/edit',
  icon: 'list ul',
  label: 'Registrations',
}
const waitingMenuConfig = {
  key: 'waiting',
  route: 'waiting',
  icon: 'clock',
  label: 'Waiting list',
}
const competitorsMenuConfig = {
  key: 'competitors',
  route: 'registrations',
  icon: 'users',
  label: 'Competitors',
}
const generalInfoMenuConfig = {
  key: 'info',
  route: '',
  icon: 'info',
  label: 'General Info',
}
const eventsMenuConfig = (icon) => ({
  key: 'events',
  icon,
  label: 'Events',
  cubing: true,
})
const scheduleMenuConfig = {
  key: 'schedule',
  icon: 'calendar',
  label: 'Schedule',
}
