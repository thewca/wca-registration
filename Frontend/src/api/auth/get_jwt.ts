import { ErrorResponse } from '../types'

export interface SuccessfulResponse {
  token: string
  error: false
}

const JWT_STORAGE_KEY = 'jwt'

export async function getJWT(
  reauthenticate = false
): Promise<ErrorResponse | SuccessfulResponse> {
  // cache the jwt token, if it has expired we just need to reauthenticate
  const cachedToken = localStorage.getItem(JWT_STORAGE_KEY)
  if (reauthenticate || cachedToken === null) {
    try {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore AUTH_URL is injected at build time
      const response = await fetch(
        `${process.env.AUTH_URL}?user_id=${localStorage.getItem('user_id')}`
      )
      if (response.ok) {
        const token = response.headers.get('authorization')
        if (token !== null) {
          localStorage.setItem(JWT_STORAGE_KEY, token)
          return { token, error: false }
        }
        // This should not happen, but I am throwing an error here regardless
        return { error: 'Did not receive a token', statusCode: 500 }
      }
      return { error: response.statusText, statusCode: response.status }
    } catch ({ name, message }) {
      return { error: `Error ${name}: ${message}`, statusCode: 500 }
    }
  } else {
    return { token: cachedToken, error: false }
  }
}
