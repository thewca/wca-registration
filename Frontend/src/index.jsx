import { createRoot } from 'react-dom/client'
import App from './pages'

// Clear the existing HTML content
document.body.innerHTML = '<div id="app"></div>'

// Render your React component instead
const root = createRoot(document.querySelector('#app'))
root.render(App())
