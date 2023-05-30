// External Styles (this is probably not the best way to load this?)
import '@thewca/wca-components/dist/index.esm.css'
import React from 'react'
import { createRoot } from 'react-dom/client'
import { createBrowserRouter, Link, RouterProvider } from 'react-router-dom'
import Registrations from './pages/registrations'
import Register from './pages/register'

const router = createBrowserRouter([
  {
    path: '/',
    element: (
      <div>
        <Link to="/register"> Register </Link>
        <Link to="/registrations"> Registrations</Link>
      </div>
    ),
  },
  {
    path: '/register',
    element: (
      <div>
        <Register />
      </div>
    ),
  },
  {
    path: '/registrations',
    element: (
      <div>
        <Registrations />
      </div>
    ),
  },
])

// Clear the existing HTML content
document.body.innerHTML = '<div id="app"></div>'

// Render your React component instead
const root = createRoot(document.querySelector('#app'))
root.render(<RouterProvider router={router} />)
