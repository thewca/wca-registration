import { getJWT, SuccessfulResponse } from '../auth/get_jwt'
import {
  DeleteRegistrationBody,
  ErrorResponse,
  GetRegistrationBody,
  SubmitRegistrationBody,
  UpdateRegistrationBody,
} from '../types'

type Method = 'POST' | 'GET' | 'PATCH' | 'DELETE'

type Body =
  | SubmitRegistrationBody
  | UpdateRegistrationBody
  | GetRegistrationBody
  | DeleteRegistrationBody

export default async function backendFetch(
  route: string,
  method: Method,
  options: {
    body?: Body
    needsAuthentication: boolean
  }
): Promise<never | ErrorResponse> {
  try {
    let init = {}
    let headers = {}
    if (options.needsAuthentication) {
      const tokenRequest = await getJWT()
      if (tokenRequest.error) {
        const { error, statusCode } = tokenRequest as ErrorResponse
        return {
          error,
          statusCode,
        }
      }
      const { token } = tokenRequest as SuccessfulResponse
      headers = {
        Authorization: token,
      }
    }
    if (method !== 'GET') {
      init = {
        method,
        body: JSON.stringify(options.body),
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
      }
    } else {
      init = {
        headers,
      }
    }
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore This is injected at build time
    const response = await fetch(`${process.env.API_URL}/${route}`, init)

    if (response.ok) {
      return await response.json()
    }
    // We always return a json error message on error
    const error = await response.json()
    if (error.status === 'Authentication Expired') {
      await getJWT(true)
      return await backendFetch(route, method, options)
    }
    return { error: error.status, statusCode: response.status }
  } catch ({ name, message }) {
    return { error: `Error ${name}: ${message}`, statusCode: 500 }
  }
}
