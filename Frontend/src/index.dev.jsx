// External Styles (this is probably not the best way to load this?)
import 'fomantic-ui-css/semantic.css'
import './global.scss'
import '@thewca/wca-components/dist/index.esm.css'
import React from 'react'
import { createRoot } from 'react-dom/client'
import { createBrowserRouter, Outlet, RouterProvider } from 'react-router-dom'
import { Container } from 'semantic-ui-react'
import HomePage from './pages/home'
import Register from './pages/register'
import RegistrationAdministration from './pages/registration_administration'
import RegistrationEdit from './pages/registration_edit'
import Registrations from './pages/registrations'
import TestLogin from './pages/test/login'
import TestLogout from './pages/test/logout'
import App from './ui/App'
import Competition from './ui/Competition'
import CustomTab from './ui/CustomTab'
import PageFooter from './ui/Footer'
import PageHeader from './ui/Header'
import FlashMessage from './ui/messages/flashMessage'
import PageTabs from './ui/Tabs'

const router = createBrowserRouter([
  {
    path: '/',
    element: (
      <App>
        <PageHeader />
        <FlashMessage />
        <main>
          <Outlet />
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
        path: '/competitions/:competition_id',
        element: (
          <Container>
            <Competition>
              <PageTabs />
              <Outlet />
            </Competition>
          </Container>
        ),
        children: [
          {
            path: '/competitions/:competition_id',
            element: <HomePage />,
          },
          {
            path: '/competitions/:competition_id/register',
            element: <Register />,
          },
          {
            path: '/competitions/:competition_id/tabs/:tab_id',
            element: <CustomTab />,
          },
          {
            path: '/competitions/:competition_id/registrations',
            element: <Registrations />,
          },
          {
            path: '/competitions/:competition_id/:user_id/edit',
            element: <RegistrationEdit />,
          },
          {
            path: '/competitions/:competition_id/registrations/edit',
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
