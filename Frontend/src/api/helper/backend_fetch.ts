import { ErrorResponse, getJWT, SuccessfulResponse } from '../auth/get_jwt'
import {
  DeleteRegistrationBody,
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

// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore we will generate response types automatically from spec soon
export default async function backendFetch(
  route: string,
  method: Method,
  body: Body = {}
) {
  try {
    let init = {}
    const tokenRequest = await getJWT()
    if (tokenRequest.error) {
      const { error, statusCode } = tokenRequest as ErrorResponse
      return {
        error,
        statusCode,
      }
    }
    const { token } = tokenRequest as SuccessfulResponse
    const headers = {
      Authorization: token,
    }
    if (method !== 'GET') {
      init = {
        method,
        body: JSON.stringify(body),
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
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
      return backendFetch(route, method, body)
    }
    return { error: response.status, statusCode: response.status }
  } catch ({ name, message }) {
    return { error: `Error ${name}: ${message}`, statusCode: 500 }
  }
}
