import React from 'react'
import { Navigate, Outlet } from 'react-router-dom'
import { Container } from 'semantic-ui-react'
import Events from './pages/events'
import HomePage from './pages/home'
import Import from './pages/import'
import Register from './pages/register'
import RegistrationAdministration from './pages/registration_administration'
import RegistrationEdit from './pages/registration_edit'
import Registrations from './pages/registrations'
import ScheduleTab from './pages/schedule'
import Waiting from './pages/waiting'
import App from './ui/App'
import Competition from './ui/Competition'
import CustomTab from './ui/CustomTab'
import FlashMessage from './ui/messages/flashMessage'
import PageTabs from './ui/PageTabs'
import PermissionsProvider from './ui/providers/PermissionsProvider'
import RegistrationProvider from './ui/providers/RegistrationProvider'
import UserProvider from './ui/providers/UserProvider'
import ScrollToTopButton from './ui/ScrollToTopButton'

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
        path: ':competition_id',
        element: (
          <Container>
            <Competition>
              <PermissionsProvider>
                <RegistrationProvider>
                  <PageTabs />
                  <Outlet />
                  <ScrollToTopButton />
                </RegistrationProvider>
              </PermissionsProvider>
            </Competition>
          </Container>
        ),
        children: [
          {
            path: '',
            element: <HomePage />,
          },
          {
            path: 'events',
            element: <Events />,
          },
          {
            path: 'schedule',
            element: <ScheduleTab />,
          },
          {
            path: 'import',
            element: <Import />,
          },
          {
            path: 'register',
            element: <Register />,
          },
          {
            path: 'tabs/:tab_id',
            element: <CustomTab />,
          },
          {
            path: `waiting`,
            element: <Waiting />,
          },
          {
            path: 'registrations',
            element: <Registrations />,
          },
          {
            path: ':user_id/edit',
            element: <RegistrationEdit />,
          },
          {
            path: 'registrations/edit',
            element: <RegistrationAdministration />,
          },
          {
            path: '*',
            element: <Navigate to="" />,
          },
        ],
      },
    ],
  },
]

export default routes
