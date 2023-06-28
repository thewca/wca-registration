import { JWT_KEY, USER_KEY } from '../../ui/App'
import { BackendError } from '../helper/backend_fetch'
import { USER_NOT_LOGGED_IN } from '../helper/error_codes'

export async function getJWT(reauthenticate = false): Promise<string> {
  // the jwt token is cached in local storage, if it has expired, we need to reauthenticate
  const cachedToken = localStorage.getItem(JWT_KEY)
  const user = localStorage.getItem(USER_KEY)
  if (user === null) {
    throw new BackendError(USER_NOT_LOGGED_IN, 401)
  }

  if (reauthenticate || cachedToken === null) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore AUTH_URL is injected at build time
    const response = await fetch(`${process.env.AUTH_URL}?user_id=${user}`)
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
