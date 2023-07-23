import { JWT_KEY } from '../../ui/providers/UserProvider'
import { BackendError } from '../helper/backend_fetch'
import getJWTMock from '../mocks/get_jwt'

export async function getJWT(reauthenticate = false): Promise<string> {
  if (process.env.NODE_ENV !== 'production') {
    return getJWTMock()
  }
  // the jwt token is cached in local storage, if it has expired, we need to reauthenticate
  const cachedToken = localStorage.getItem(JWT_KEY)
  if (reauthenticate || cachedToken === null) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore AUTH_URL is injected at build time
    const response = await fetch(process.env.AUTH_URL)
    const body = await response.json()
    if (response.ok) {
      const token = response.headers.get('authorization')
      if (token !== null) {
        localStorage.setItem(JWT_KEY, token)
        return token
      }
      // This should not happen, but I am throwing an error here regardless
      throw new BackendError(body.error, 500)
    }
    throw new BackendError(body.error, response.status)
  } else {
    return cachedToken
  }
}
