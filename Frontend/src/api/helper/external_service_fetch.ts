import { BackendError } from './backend_fetch'

export default async function externalServiceFetch(route: string) {
  const response = await fetch(route)
  const body = await response.json()
  if (response.ok) {
    return body
  }

  throw new BackendError(body.error, response.status)
}
