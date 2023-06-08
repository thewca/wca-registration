export type SuccessfullResponse = {
  token: string
  error: false
}

export type ErrorResponse = {
  error: string
  statusCode: number
}

export async function getJWT(
  reauthenticate = false
): Promise<ErrorResponse | SuccessfullResponse> {
  // cache the jwt token, if it has expired we just need to reauthenticate
  if (reauthenticate || localStorage.getItem('jwt') === null) {
    try {
      // @ts-ignore AUTH_URL is injected at build time
      const response = await fetch(`${process.env.AUTH_URL}`)
      console.log(response)
      const token = response.headers.get('authorization')
      if (response.ok && token !== null) {
        localStorage.setItem('jwt', token)
        return { token: token, error: false }
      }
      return { error: response.statusText, statusCode: response.status }
    } catch ({ name, message }) {
      return { error: `Error ${name}: ${message}`, statusCode: 500 }
    }
  } else {
    return { token: localStorage.getItem('jwt') || '', error: false }
  }
}
