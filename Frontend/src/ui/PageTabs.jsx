import { CubingIcon, UiIcon } from '@thewca/wca-components'
import React, { useContext, useMemo } from 'react'
import { useTranslation } from 'react-i18next'
import { useLocation, useNavigate } from 'react-router-dom'
import { Dropdown, Menu } from 'semantic-ui-react'
import { CompetitionContext } from '../api/helper/context/competition_context'
import { PermissionsContext } from '../api/helper/context/permission_context'
import i18n from '../i18n'
import { hasPassed } from '../lib/dates'
import { BASE_ROUTE } from '../routes'

export default function PageTabs() {
  const { competitionInfo } = useContext(CompetitionContext)
  const { canAdminCompetition } = useContext(PermissionsContext)

  const navigate = useNavigate()
  const location = useLocation()

  const { t } = useTranslation('translation', { i18n })

  const menuItems = useMemo(() => {
    const optionalTabs = []

    if (competitionInfo.use_wca_registration) {
      optionalTabs.push(registerMenuConfig)
    }
    if (canAdminCompetition) {
      optionalTabs.push(registrationsMenuConfig)
      optionalTabs.push(waitingMenuConfig)
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
    canAdminCompetition,
  ])

  const customTabActive = useMemo(() => {
    return competitionInfo.tabs.some((competitionTab) =>
      pathMatch(competitionTab.id, location.pathname),
    )
  }, [competitionInfo.tabs, location])

  const hasCustomTabs = competitionInfo.tabs.length > 0

  return (
    <Menu
      attached
      fluid
      widths={menuItems.length + (hasCustomTabs ? 1 : 0)}
      size="huge"
      stackable
    >
      {menuItems.map((menuConfig) => (
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
          {menuConfig.cubing && <CubingIcon event={menuConfig.icon} selected />}
          {menuConfig.icon && !menuConfig.cubing && (
            <UiIcon name={menuConfig.icon} />
          )}
          {t(menuConfig.i18nKey)}
        </Menu.Item>
      ))}

      {hasCustomTabs && (
        <Dropdown
          item
          text={t('competitions.registration_v2.tabs.more')}
          className={customTabActive ? 'active' : ''}
        >
          <Dropdown.Menu>
            {competitionInfo.tabs.map((competitionTab) => (
              <Dropdown.Item
                key={competitionTab.id}
                onClick={() =>
                  navigate(
                    `${BASE_ROUTE}/${competitionInfo.id}/tabs/${competitionTab.id}`,
                  )
                }
                active={pathMatch(competitionTab.id, location.pathname)}
              >
                {competitionTab.name}
              </Dropdown.Item>
            ))}
          </Dropdown.Menu>
        </Dropdown>
      )}
    </Menu>
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
  i18nKey: 'competitions.nav.menu.register',
}
const registrationsMenuConfig = {
  key: 'registrations',
  route: 'registrations/edit',
  icon: 'list ul',
  i18nKey: 'competitions.nav.menu.registration',
}
const waitingMenuConfig = {
  key: 'waiting',
  route: 'waiting',
  icon: 'clock',
  i18nKey: 'registrations.list.waiting_list',
}
const competitorsMenuConfig = {
  key: 'competitors',
  route: 'registrations',
  icon: 'users',
  i18nKey: 'competitions.nav.menu.competitors',
}
const generalInfoMenuConfig = {
  key: 'info',
  route: '',
  icon: 'info',
  i18nKey: 'competitions.show.general_info',
}
const eventsMenuConfig = (icon) => ({
  key: 'events',
  icon,
  i18nKey: 'competitions.show.events',
  cubing: true,
})
const scheduleMenuConfig = {
  key: 'schedule',
  icon: 'calendar',
  i18nKey: 'competitions.show.schedule',
}
