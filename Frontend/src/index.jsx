// External Styles (this is probably not the best way to load this?)
import '@thewca/wca-components/dist/index.esm.css'
import React from 'react'
import { createRoot } from 'react-dom/client'
import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import routes from './routes'
import './i18n'

const router = createBrowserRouter(routes)

// Render the React component into the body of the monolith
const root = createRoot(document.querySelector('#registration-app'))
root.render(<RouterProvider router={router} />)
