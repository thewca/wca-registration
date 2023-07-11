import { getJWT } from '../auth/get_jwt'
import {
  GetRegistrationBody,
  SubmitRegistrationBody,
  UpdateRegistrationBody,
} from '../types'
import { EXPIRED_TOKEN } from './error_codes'

type Method = 'POST' | 'GET' | 'PATCH' | 'DELETE'

type Body =
  | SubmitRegistrationBody
  | UpdateRegistrationBody
  | GetRegistrationBody

export class BackendError extends Error {
  errorCode: number
  httpCode: number
  constructor(errorCode: number, httpCode: number) {
    super(`Error ${errorCode}, httpCode: ${httpCode}`)
    this.errorCode = errorCode
    this.httpCode = httpCode
  }
}

export default async function backendFetch(
  route: string,
  method: Method,
  options: {
    body?: Body
    needsAuthentication: boolean
  }
): Promise<unknown> {
  let init = {}
  let headers = {}
  if (options.needsAuthentication) {
    const token = await getJWT()
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
  if (body.error === EXPIRED_TOKEN) {
    await getJWT(true)
    return backendFetch(route, method, options)
  }
  throw new BackendError(body.error, response.status)
}
