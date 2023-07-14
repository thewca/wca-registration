import fetch from 'sync-fetch'
import { BackendError } from './backend_fetch'

export default function externalServiceFetch(route: string) {
  const response = fetch(route)
  const body = response.json()
  if (response.ok) {
    return body
  }

  throw new BackendError(body.error, response.status)
}
