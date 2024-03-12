// Only import what we actually need to not overwrite css rules
import '@thewca/wca-components/dist/css/CubingIcon/index.css'
import '@thewca/wca-components/dist/css/FlagIcon/index.css'
import '@thewca/wca-components/dist/css/UiIcon/index.css'
import '@thewca/wca-components/dist/css/EventSelector/index.css'
import React from 'react'
import { createRoot } from 'react-dom/client'
import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import routes from './routes'

const router = createBrowserRouter(routes)

// Render the React component into the body of the monolith
const root = createRoot(document.querySelector('#registration-app'))
root.render(<RouterProvider router={router} />)
