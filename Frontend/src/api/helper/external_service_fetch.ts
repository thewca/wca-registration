import { BackendError } from './backend_fetch'

export default async function externalServiceFetch(
  route: string,
  options = {},
  needsResponse = true,
) {
  const response = await fetch(route, options)
  if (needsResponse) {
    const body = await response.json()
    if (response.ok) {
      return body
    }

    throw new BackendError(body.error, response.status)
  } else {
    return response.ok
  }
}
