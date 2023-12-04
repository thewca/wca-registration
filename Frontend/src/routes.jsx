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
import Schedule from './pages/schedule'
import App from './ui/App'
import Competition from './ui/Competition'
import CustomTab from './ui/CustomTab'
import FlashMessage from './ui/messages/flashMessage'
import PageTabs from './ui/PageTabs'
import PermissionsProvider from './ui/providers/PermissionsProvider'
import UserProvider from './ui/providers/UserProvider'

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
                <PageTabs />
                <Outlet />
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
            element: <Schedule />,
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
