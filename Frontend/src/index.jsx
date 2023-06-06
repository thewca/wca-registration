// External Styles (this is probably not the best way to load this?)
import '@thewca/wca-components/dist/index.esm.css'
import 'fomantic-ui-css/semantic.css'
import './global.scss'
import React from 'react'
import { createRoot } from 'react-dom/client'
import { createBrowserRouter, Outlet, RouterProvider } from 'react-router-dom'
import Register from './pages/register'
import Registrations from './pages/registrations'
import PageFooter from './ui/Footer'
import PageHeader from './ui/Header'

const router = createBrowserRouter([
  {
    path: '/',
    element: (
      <>
        <PageHeader />
        <Outlet />
        <PageFooter />
      </>
    ),
    children: [
      {
        path: '/register',
        element: (
          <main>
            <Register />
          </main>
        ),
      },
      {
        path: '/registrations',
        element: (
          <main>
            <Registrations />
          </main>
        ),
      },
    ],
  },
])

// Clear the existing HTML content
document.body.innerHTML = '<div id="app"></div>'

// Render your React component instead
const root = createRoot(document.querySelector('#app'))
root.render(<RouterProvider router={router} />)
