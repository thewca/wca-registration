import {
  DeleteRegistrationBody,
  GetRegistrationBody,
  SubmitRegistrationBody,
  UpdateRegistrationBody,
} from '../types'
import { ErrorResponse, getJWT, SuccessfullResponse } from '../auth/get_jwt'

type Method = 'POST' | 'GET' | 'PATCH' | 'DELETE'

type Body =
  | SubmitRegistrationBody
  | UpdateRegistrationBody
  | GetRegistrationBody
  | DeleteRegistrationBody

// @ts-ignore we will generate response types automatically from spec
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
        error: error,
        statusCode: statusCode,
      }
    }
    const { token } = tokenRequest as SuccessfullResponse
    let headers = {
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
    // @ts-ignore This is injected at build time
    const response = await fetch(`${process.env.API_URL}/${route}`, init)

    if (response.ok) {
      return await response.json()
    } else {
      // We always return a json error message on error
      const error = await response.json()
      if (error.status === 'Authentication Expired') {
        await getJWT(true)
        return backendFetch(route, method, body)
      }
      return { error: response.status, statusCode: response.status }
    }
  } catch ({ name, message }) {
    return { error: `Error ${name}: ${message}`, statusCode: 500 }
  }
}
