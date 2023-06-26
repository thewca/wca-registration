import { USER_KEY } from '../helper/hooks/use_user'
import { ErrorResponse, UserType } from '../types'

export interface SuccessfulResponse {
  token: string
  error: false
}

// User is now an object in localstorage with id and authToken
const getUser: () => UserType | undefined = () => {
  const user = localStorage.getItem(USER_KEY)
  if (user) {
    return JSON.parse(user) as UserType
  }
}
// This might cause React's authToken string in the user Context to become
// out of sync. Currently it doesn't matter because it is never used in a React Context.
// This issue should go away once we integrate with the monolith, but we might
// need to convert all these functions to React hooks if it doesn't
const setToken = (token: string) => {
  const user = localStorage.getItem(USER_KEY)
  if (user) {
    const parsedUser = JSON.parse(user) as UserType
    parsedUser.authToken = token
    localStorage.setItem(USER_KEY, JSON.stringify(parsedUser))
  }
}
export async function getJWT(
  reauthenticate = false
): Promise<ErrorResponse | SuccessfulResponse> {
  // the jwt token is cached in the user object in local storage, if it has expired, we need to reauthenticate
  const user = getUser()
  const cachedToken = user!.authToken
  if (reauthenticate || cachedToken === undefined) {
    try {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore AUTH_URL is injected at build time
      const response = await fetch(`${process.env.AUTH_URL}?user_id=${user.id}`)
      if (response.ok) {
        const token = response.headers.get('authorization')
        if (token !== null) {
          setToken(token)
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
