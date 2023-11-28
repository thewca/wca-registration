// External Styles (this is probably not the best way to load this?)
import 'fomantic-ui-css/semantic.css'
import './global.scss'
import '@thewca/wca-components/dist/index.esm.css'
import React from 'react'
import { createRoot } from 'react-dom/client'
import { createBrowserRouter, Outlet, RouterProvider } from 'react-router-dom'
import { Container } from 'semantic-ui-react'
import Events from './pages/events'
import HomePage from './pages/home'
import Import from './pages/import'
import Register from './pages/register'
import RegistrationAdministration from './pages/registration_administration'
import RegistrationEdit from './pages/registration_edit'
import Registrations from './pages/registrations'
import Schedule from './pages/schedule'
import TestLogin from './pages/test/login'
import TestLogout from './pages/test/logout'
import { BASE_ROUTE } from './routes'
import App from './ui/App'
import Competition from './ui/Competition'
import CustomTab from './ui/CustomTab'
import PageFooter from './ui/Footer'
import PageHeader from './ui/Header'
import FlashMessage from './ui/messages/flashMessage'
import PermissionsProvider from './ui/providers/PermissionsProvider'
import UserProvider from './ui/providers/UserProvider'
import PageTabs from './ui/Tabs'
import Waiting from './pages/waiting'

const router = createBrowserRouter([
  {
    path: '/',
    element: (
      <App>
        <PageHeader />
        <FlashMessage />
        <main>
          <UserProvider>
            <Outlet />
          </UserProvider>
        </main>
        <PageFooter />
      </App>
    ),
    children: [
      {
        // Test Route to simulate different users
        path: '/login/:login_id',
        element: <TestLogin />,
      },
      {
        // Test Route to simulate different users
        path: '/logout',
        element: <TestLogout />,
      },
      {
        path: '',
        element: (
          <h1 style={{ position: 'absolute', right: '35%' }}>
            Choose a Test Competition from the Menu
          </h1>
        ),
      },
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
            path: `${BASE_ROUTE}/:competition_id/import`,
            element: <Import />,
          },
          {
            path: `${BASE_ROUTE}/:competition_id/schedule`,
            element: <Schedule />,
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
])

// Clear the existing HTML content
document.body.innerHTML = '<div id="app"></div>'

// Render your React component instead
const root = createRoot(document.querySelector('#app'))
root.render(<RouterProvider router={router} />)
