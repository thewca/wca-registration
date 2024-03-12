import { BackendError } from '../helper/error_codes'
import { tokenRoute } from '../helper/routes'
import getJWTMock from '../mocks/get_jwt'

const JWT_KEY = 'jwt'

export async function getJWT(reauthenticate = false): Promise<string> {
  if (process.env.NODE_ENV !== 'production') {
    return getJWTMock()
  }
  // the jwt token is cached in local storage, if it has expired, we need to reauthenticate
  const cachedToken = localStorage.getItem(JWT_KEY)
  if (reauthenticate || cachedToken === null) {
    const response = await fetch(tokenRoute)
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
