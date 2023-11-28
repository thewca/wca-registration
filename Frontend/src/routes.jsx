import React from 'react'
import { Outlet } from 'react-router-dom'
import { Container } from 'semantic-ui-react'
import Events from './pages/events'
import HomePage from './pages/home'
import Import from './pages/import'
import Register from './pages/register'
import RegistrationAdministration from './pages/registration_administration'
import RegistrationEdit from './pages/registration_edit'
import Registrations from './pages/registrations'
import Schedule from './pages/schedule'
import Waiting from './pages/waiting'
import App from './ui/App'
import Competition from './ui/Competition'
import CustomTab from './ui/CustomTab'
import FlashMessage from './ui/messages/flashMessage'
import PermissionsProvider from './ui/providers/PermissionsProvider'
import UserProvider from './ui/providers/UserProvider'
import PageTabs from './ui/Tabs'

export const BASE_ROUTE = '/competitions/v2'

const routes = [
  {
    path: BASE_ROUTE,
    element: (
      <App>
        <FlashMessage />
        <UserProvider>
          <Outlet />
        </UserProvider>
      </App>
    ),
    children: [
      {
        path: `${BASE_ROUTE}/:competition_id`,
        element: (
          <Container>
            <Competition>
              <PermissionsProvider>
                <PageTabs />
                <Outlet />
              </PermissionsProvider>
            </Competition>
          </Container>
        ),
        children: [
          {
            path: `${BASE_ROUTE}/:competition_id`,
            element: <HomePage />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/events`,
            element: <Events />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/schedule`,
            element: <Schedule />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/import`,
            element: <Import />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/register`,
            element: <Register />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/waiting`,
            element: <Waiting />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/tabs/:tab_id`,
            element: <CustomTab />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/registrations`,
            element: <Registrations />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/:user_id/edit`,
            element: <RegistrationEdit />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/registrations/edit`,
            element: <RegistrationAdministration />,
          },
        ],
      },
    ],
  },
]

export default routes
