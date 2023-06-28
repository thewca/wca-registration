// External Styles (this is probably not the best way to load this?)
import 'fomantic-ui-css/semantic.css'
import './global.scss'
import '@thewca/wca-components/dist/index.esm.css'
import React from 'react'
import { createRoot } from 'react-dom/client'
import { createBrowserRouter, Outlet, RouterProvider } from 'react-router-dom'
import HomePage from './pages/home'
import Register from './pages/register'
import RegistrationAdministration from './pages/registration_administration'
import RegistrationEdit from './pages/registration_edit'
import Registrations from './pages/registrations'
import TestLogin from './pages/test/login'
import TestLogout from './pages/test/logout'
import App from './ui/App'
import PageFooter from './ui/Footer'
import PageHeader from './ui/Header'
import FlashMessage from './ui/./messages/flashMessage'
import PageSidebar from './ui/Sidebar'

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
        path: '/:competition_id',
        element: (
          <>
            <PageSidebar />
            <Outlet />
          </>
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

// Clear the existing HTML content
document.body.innerHTML = '<div id="app"></div>'

// Render your React component instead
const root = createRoot(document.querySelector('#app'))
root.render(<RouterProvider router={router} />)
