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
import App from './ui/App'
import Competition from './ui/Competition'
import FlashMessage from './ui/messages/flashMessage'
import PageTabs from './ui/Tabs'

const router = createBrowserRouter([
  {
    path: '/competitions',
    element: (
      <App>
        <FlashMessage />
        <Outlet />
      </App>
    ),
    children: [
      {
        path: '/:competition_id',
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
            path: '/:competition_id',
            element: <HomePage />,
          },
          {
            path: '/:competition_id/register',
            element: <Register />,
          },
          {
            path: '/:competition_id/registrations',
            element: <Registrations />,
          },
          {
            path: '/:competition_id/:user_id/edit',
            element: <RegistrationEdit />,
          },
          {
            path: '/:competition_id/registrations/edit',
            element: <RegistrationAdministration />,
          },
        ],
      },
    ],
  },
])

// Render the React component into the body of the monolith
const root = createRoot(document.querySelector('#registration-app'))
root.render(<RouterProvider router={router} />)
