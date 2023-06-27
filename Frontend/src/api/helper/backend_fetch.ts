import { getJWT, SuccessfulResponse } from '../auth/get_jwt'
import {
  ErrorResponse,
  GetRegistrationBody,
  SubmitRegistrationBody,
  UpdateRegistrationBody,
} from '../types'
import { EXPIRED_TOKEN_STATUS_CODE } from './error_codes'

type Method = 'POST' | 'GET' | 'PATCH' | 'DELETE'

type Body =
  | SubmitRegistrationBody
  | UpdateRegistrationBody
  | GetRegistrationBody

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
        return tokenRequest as ErrorResponse
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
    // We always return a json error message, even on error
    const body = await response.json()
    if (response.ok) {
      return body
    }
    if (body.error === EXPIRED_TOKEN_STATUS_CODE) {
      await getJWT(true)
      return await backendFetch(route, method, options)
    }
    return { error: body.error, statusCode: response.status }
  } catch ({ name, message }) {
    return { error: `Error ${name}: ${message}`, statusCode: 500 }
  }
}
