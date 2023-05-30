import { createRoot } from 'react-dom/client'
import App from './register/pages'

// External Styles (this is probably not the best way to load this?)
import '@thewca/wca-components/dist/index.esm.css'

// Clear the existing HTML content
document.body.innerHTML = '<div id="app"></div>'

// Render your React component instead
const root = createRoot(document.querySelector('#app'))
root.render(App())
