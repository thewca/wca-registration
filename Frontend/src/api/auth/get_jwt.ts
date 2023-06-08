export interface SuccessfulResponse {
  token: string
  error: false
}

export interface ErrorResponse {
  error: string
  statusCode: number
}

export async function getJWT(
  reauthenticate = false
): Promise<ErrorResponse | SuccessfulResponse> {
  // cache the jwt token, if it has expired we just need to reauthenticate
  if (reauthenticate || localStorage.getItem('jwt') === null) {
    try {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore AUTH_URL is injected at build time
      const response = await fetch(`${process.env.AUTH_URL}`)
      const token = response.headers.get('authorization')
      if (response.ok && token !== null) {
        localStorage.setItem('jwt', token)
        return { token, error: false }
      }
      return { error: response.statusText, statusCode: response.status }
    } catch ({ name, message }) {
      return { error: `Error ${name}: ${message}`, statusCode: 500 }
    }
  } else {
    return { token: localStorage.getItem('jwt') || '', error: false }
  }
}
